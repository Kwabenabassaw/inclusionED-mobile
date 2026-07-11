### Audio & Media Playback Constraints
- **Lifecycle Cleanup:** Whenever implementing a screen or widget that plays audio/video, ALWAYS explicitly stop the playback in the widget's `dispose()` method or equivalent lifecycle teardown. Never let audio orphan itself in the background unless it's an explicit global music player.
- **Playback Speed Ranges:** When implementing playback speed sliders, the `max` value should typically be `2.0` or `3.0` (for 2x or 3x speed). Do not cap speed sliders at `1.0`, as this is typically the baseline 1x speed for most engines like `just_audio`.
