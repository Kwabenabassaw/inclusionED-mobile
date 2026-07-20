import { PollyClient, SynthesizeSpeechCommand } from "npm:@aws-sdk/client-polly";

const polly = new PollyClient({
  region: 'us-east-1',
  credentials: {
    accessKeyId: 'fake',
    secretAccessKey: 'fake',
  },
});

console.log("SynthesizeSpeechCommand:", typeof SynthesizeSpeechCommand);

async function test() {
  try {
    const audioCommand = new SynthesizeSpeechCommand({
      Engine: "neural",
      LanguageCode: "en-US",
      OutputFormat: "mp3",
      Text: "<speak>Hello</speak>",
      TextType: "ssml",
      VoiceId: "Joanna",
    });
    
    console.log("Sending command...");
    const res = await polly.send(audioCommand);
    console.log(res);
  } catch (e: any) {
    console.log("Error:", e.message);
  }
}

test();
