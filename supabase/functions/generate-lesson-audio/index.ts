import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { PollyClient, SynthesizeSpeechCommand } from "npm:@aws-sdk/client-polly";
import { FetchHttpHandler } from "npm:@smithy/fetch-http-handler";
import * as jose from "https://deno.land/x/jose@v4.14.4/index.ts";
import { normalize } from "./text_normalizer.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') || 'inclusioned-e0383';
let publicKeys: Record<string, string> | null = null;
let publicKeysCacheTime = 0;

async function getFirebasePublicKeys() {
  const now = Date.now();
  if (publicKeys && now - publicKeysCacheTime < 3600000) {
    return publicKeys;
  }
  const res = await fetch("https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com");
  publicKeys = await res.json();
  publicKeysCacheTime = now;
  return publicKeys;
}

async function verifyFirebaseToken(token: string) {
  const keys = await getFirebasePublicKeys();
  const header = jose.decodeProtectedHeader(token);
  
  if (!header.kid || !keys[header.kid]) {
    throw new Error("Invalid token kid");
  }
  
  const cert = keys[header.kid];
  const publicKey = await jose.importX509(cert, 'RS256');
  const { payload } = await jose.jwtVerify(token, publicKey, {
    issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
    audience: FIREBASE_PROJECT_ID,
  });
  
  return payload;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { 
        status: 401, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      });
    }
    
    const token = authHeader.substring(7);
    const decodedPayload = await verifyFirebaseToken(token);

    const { lessonId, text, voice } = await req.json();

    if (!lessonId || !text || !voice) {
      return new Response(JSON.stringify({ error: "Missing lessonId, text, or voice" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const fileName = `${lessonId}_${voice}.mp3`;
    const marksFileName = `${lessonId}_${voice}.json`;
    const alignmentFileName = `${lessonId}_${voice}_alignment.json`;
    
    const { data: listData } = await supabase
      .storage
      .from('tts')
      .list('', {
        search: `${lessonId}_${voice}`
      });

    const hasAudio = listData?.some(f => f.name === fileName);
    const hasMarks = listData?.some(f => f.name === marksFileName);
    const hasAlignment = listData?.some(f => f.name === alignmentFileName);

    if (hasAudio && hasMarks && hasAlignment) {
      const [audioUrlData, marksUrlData, alignmentUrlData] = await Promise.all([
        supabase.storage.from('tts').createSignedUrl(fileName, 3600),
        supabase.storage.from('tts').createSignedUrl(marksFileName, 3600),
        supabase.storage.from('tts').createSignedUrl(alignmentFileName, 3600),
      ]);

      return new Response(JSON.stringify({ 
        signedUrl: audioUrlData.data?.signedUrl,
        marksUrl: marksUrlData.data?.signedUrl,
        alignmentUrl: alignmentUrlData.data?.signedUrl,
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    const polly = new PollyClient({
      region: Deno.env.get('AWS_REGION') || 'us-east-1',
      credentials: {
        accessKeyId: Deno.env.get('AWS_ACCESS_KEY_ID')!,
        secretAccessKey: Deno.env.get('AWS_SECRET_ACCESS_KEY')!,
      },
      requestHandler: new FetchHttpHandler(),
    });

    // Normalize the raw text: get SSML for Polly + alignment map for highlighting
    const normalized = normalize(text);
    const alignmentJson = JSON.stringify(normalized.alignmentMap);

    const audioCommand = new SynthesizeSpeechCommand({
      Engine: "neural",
      LanguageCode: "en-US",
      OutputFormat: "mp3",
      Text: normalized.ssml,
      TextType: "ssml",
      VoiceId: voice,
    });

    const marksCommand = new SynthesizeSpeechCommand({
      Engine: "neural",
      LanguageCode: "en-US",
      OutputFormat: "json",
      SpeechMarkTypes: ["word"],
      Text: normalized.ssml,
      TextType: "ssml",
      VoiceId: voice,
    });

    const audioResponse = await polly.send(audioCommand);
    const marksResponse = await polly.send(marksCommand);

    if (!audioResponse.AudioStream || !marksResponse.AudioStream) {
      throw new Error("No audio or marks stream returned from Polly");
    }

    const audioData = await audioResponse.AudioStream.transformToByteArray();
    const marksData = await marksResponse.AudioStream.transformToByteArray();
    const alignmentData = new TextEncoder().encode(alignmentJson);

    const [audioUpload, marksUpload, alignmentUpload] = await Promise.all([
      supabase.storage.from('tts').upload(fileName, audioData, { contentType: 'audio/mpeg', upsert: true }),
      supabase.storage.from('tts').upload(marksFileName, marksData, { contentType: 'application/json', upsert: true }),
      supabase.storage.from('tts').upload(alignmentFileName, alignmentData, { contentType: 'application/json', upsert: true }),
    ]);

    if (audioUpload.error) throw audioUpload.error;
    if (marksUpload.error) throw marksUpload.error;
    if (alignmentUpload.error) throw alignmentUpload.error;

    const [audioUrlData, marksUrlData, alignmentUrlData] = await Promise.all([
      supabase.storage.from('tts').createSignedUrl(fileName, 3600),
      supabase.storage.from('tts').createSignedUrl(marksFileName, 3600),
      supabase.storage.from('tts').createSignedUrl(alignmentFileName, 3600),
    ]);

    if (audioUrlData.error) throw audioUrlData.error;
    if (marksUrlData.error) throw marksUrlData.error;
    if (alignmentUrlData.error) throw alignmentUrlData.error;

    return new Response(JSON.stringify({ 
      signedUrl: audioUrlData.data?.signedUrl,
      marksUrl: marksUrlData.data?.signedUrl,
      alignmentUrl: alignmentUrlData.data?.signedUrl,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error: any) {
    console.error("Error in generate-lesson-audio:", error);
    return new Response(JSON.stringify({ error: error.message, stack: error.stack, fullError: String(error) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
