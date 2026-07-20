### Audio & Media Playback Constraints
- **Lifecycle Cleanup:** Whenever implementing a screen or widget that plays audio/video, ALWAYS explicitly stop the playback in the widget's `dispose()` method or equivalent lifecycle teardown. Never let audio orphan itself in the background unless it's an explicit global music player.
- **Playback Speed Ranges:** When implementing playback speed sliders, the `max` value should typically be `2.0` or `3.0` (for 2x or 3x speed). Do not cap speed sliders at `1.0`, as this is typically the baseline 1x speed for most engines like `just_audio`.

### Background Services & Global Listeners
- **Lifecycle Integration Verification:** Whenever implementing a background service, global event listener, or hardware sensor stream (e.g., microphone wake-word, geolocation tracking), you MUST explicitly verify its initialization path. 
- Do not stop at creating the service class and the UI toggle. ALWAYS confirm that the service is actively injected and initialized in the widget tree (e.g., via eager Riverpod initialization, `main.dart`, or a root provider listener) and that state changes successfully trigger the service's start/stop methods.
