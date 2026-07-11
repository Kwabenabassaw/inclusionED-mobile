---
name: integrating-mux
description: Implements Mux video streaming infrastructure in a Flutter and Supabase project. Use when the user wants to integrate Mux, set up HLS streaming, or add video encoding webhooks.
---

# Integrating Mux Video Infrastructure

## When to use this skill
- Integrating Mux for video streaming
- Migrating from raw MP4s to adaptive HLS streaming
- Setting up a Mux webhook listener in Supabase Edge Functions
- Replacing `video_player` with `media_kit` for vertical feeds

## Workflow
1. **[ ] Database Schema:** Create a Supabase migration to add `mux_asset_id`, `mux_playback_id`, and `status` to the `creator_videos` table.
2. **[ ] Backend Webhook:** Create a Supabase Edge Function (`mux-webhook`) that listens to Mux `video.asset.ready` events and updates the database row status. Ensure to verify the Mux webhook signature.
3. **[ ] Flutter Storage Update:** Refactor upload logic to first upload to Supabase Storage, then dispatch a request (via Edge Function) to Mux to create the asset using the storage URL.
4. **[ ] Realtime Subscriptions:** Configure the Flutter client to listen to Supabase Realtime updates on the `creator_videos` table so the UI can transition from processing to playing.
5. **[ ] Flutter Playback Migration:** Replace `video_player` with `media_kit` and `media_kit_video` in vertical feeds like `lib/Feed/creator_video_player.dart`.
6. **[ ] Video Preloading:** Implement or update `lib/core/video_controller_pool.dart` to maintain a strict maximum of 3 active `media_kit` controllers to prevent GPU Out-of-Memory crashes.
7. **[ ] Dynamic Thumbnails:** Embellish `VideoPlayer` UI placeholders using Mux dynamic animated WebPs (`image.mux.com/<PLAYBACK_ID>/animated.webp`).

## Instructions

### 1. Database Schema Additions
```sql
ALTER TABLE public.creator_videos
ADD COLUMN mux_asset_id TEXT,
ADD COLUMN mux_playback_id TEXT,
ADD COLUMN status TEXT DEFAULT 'processing',
ADD COLUMN duration_seconds NUMERIC;

CREATE INDEX idx_mux_playback ON public.creator_videos(mux_playback_id);
```

### 2. Edge Function (Mux Webhook)
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import Mux from "npm:@mux/mux-node"
import { createClient } from "npm:@supabase/supabase-js"

serve(async (req) => {
  const payload = await req.text()
  const isValid = Mux.Webhooks.verifyHeader(payload, req.headers.get('mux-signature'), Deno.env.get('MUX_WEBHOOK_SECRET'))
  if (!isValid) return new Response("Unauthorized", { status: 401 })

  const event = JSON.parse(payload)
  if (event.type === 'video.asset.ready') {
    const asset = event.data; const videoId = asset.passthrough
    const supabase = createClient(Deno.env.get('SUPABASE_URL'), Deno.env.get('SUPABASE_SERVICE_ROLE_KEY'))
    await supabase.from('creator_videos').update({
      mux_asset_id: asset.id,
      mux_playback_id: asset.playback_ids[0].id,
      status: 'ready',
      duration_seconds: asset.duration
    }).eq('id', videoId)
  }
  return new Response("OK", { status: 200 })
})
```

### 3. Flutter Client `media_kit` Migration
When rendering `m3u8` feeds on Flutter, `media_kit` is preferred. Initialize a player:
```dart
final player = Player();
// Mux HLS Streaming URL
player.open(Media('https://stream.mux.com/$muxPlaybackId.m3u8'), play: false);
```

Always dispose of the player when the feed item is ≥ 2 spaces away from the active viewport.

## Resources
- Ensure `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET`, and `MUX_WEBHOOK_SECRET` are added to Supabase vault/edge function secrets before deploying the webhook.
