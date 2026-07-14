---
name: accessibility-audit
description: Use this skill to perform a full accessibility readiness review of the Flutter LMS app — TTS/STT pipeline, voice command system, text normalization, highlighter sync, font scaling, and general WCAG-aligned mobile accessibility. Trigger this whenever the user asks to "review," "audit," "check accessibility," or "is this ready to present/ship" for the app, or after any accessibility-related feature is implemented or changed.
---

# Accessibility Readiness Audit — Flutter LMS App

## Purpose

This app's core value proposition is accessibility for students with visual
impairments. A single broken assumption (a desynced highlighter, a silent
crash, a setting that visually changes but does nothing) is not a minor bug
here — it can make a core screen genuinely unusable for the exact users the
app exists to serve. This skill exists to catch those failures systematically,
not just review code for general quality.

Do not perform a generic Flutter code review. Every finding must be evaluated
against one question: **would this fail silently or confusingly for a user
who cannot see the screen, or who has low vision?**

## How to run this audit

Work through the sections below in order. For each section:
1. Locate the relevant code (search the codebase, don't assume file names)
2. Check it against every item in that section's checklist
3. Classify each finding as **Blocker**, **Major**, or **Minor** (see severity
   guide at the end)
4. Do not fix anything during the audit pass — produce a findings report
   first. Fixing during discovery causes incomplete audits, since fixing one
   issue can mask or shift another.

Only after the full report is reviewed and approved should fixes begin, and
they should be tackled one finding at a time, verified against the specific
"how to verify" step listed for that finding, not batched together.

---

## Section 1 — TTS Playback Integrity

Check the PlaybackState machine and every call site of TTS start/stop.

- [ ] Confirm a single enum/state machine owns ALL playback state (idle,
      speaking, pausedByUser, restartingForSettings, stoppedForNavigation, or
      equivalent). Flag any local `bool isPlaying` or duplicate state living
      outside this machine as a **Blocker** — this is the root cause class
      behind pause-doesn't-pause and highlighter-desync bugs.
- [ ] Every call to stop/cancel playback is preceded by an explicit state
      assignment declaring *why* it's stopping. Any stop() call without a
      preceding state assignment is a **Blocker**.
- [ ] Pause actually pauses (does not restart from position 0). Verify by
      pausing mid-sentence, waiting 5 seconds, resuming — audio must resume
      from the paused point, not the start of the file or the start of the
      lesson.
- [ ] Changing playback speed does not restart audio or trigger a network
      call — it must be a live, client-side operation on already-loaded
      audio.
- [ ] Changing voice or pitch (if regeneration is required) resumes from the
      nearest equivalent position after the new audio loads — it must not
      silently restart from 0. If exact position mapping isn't feasible,
      confirm there's a documented, intentional fallback (e.g. "restart from
      current paragraph"), not an accidental one.
- [ ] Navigating away from a screen (next/prev/back/tab switch) always stops
      audio immediately. Test rapid next/prev taps — audio must never
      continue playing over a screen the user has left, and must never leave
      an orphaned player/session running.
- [ ] If pitch controls are exposed in the UI, confirm they only appear when
      the underlying TTS engine actually supports pitch adjustment for the
      active voice (e.g. Polly Standard vs Neural). A visible control that
      silently does nothing is a **Major** finding — the user has no way to
      know it failed.

## Section 2 — Highlighter Synchronization

- [ ] Confirm word-level timing data exists at all (e.g. Polly Speech Marks,
      or the TTS engine's native progress/word-boundary callback). If no
      timing data is being generated or fetched, the highlighter cannot
      possibly work correctly — flag as **Blocker** and trace back to
      whichever synthesis call is missing it.
- [ ] Confirm highlighting is driven by an alignment mapping between
      displayText and speechText (not a raw 1:1 word-index assumption), if
      text normalization has changed word counts between the two (numbers,
      abbreviations, symbols expanded for speech). Highlighting the wrong
      word due to index drift is a **Major** finding — it actively misleads
      a low-vision reader following along visually.
- [ ] Highlighting stays correctly synced through: a playback speed change,
      a pause/resume cycle, and a voice/pitch regeneration (new audio + new
      timing data loaded as a pair, never independently).
- [ ] Highlight contrast meets WCAG AA minimum (3:1 against background for
      large/bold text used in highlights) — check the actual highlight color
      against the actual background color, don't assume.
- [ ] Highlighter resets/clears correctly when leaving the screen or when
      playback stops for any reason — a "stuck" highlight left over after
      navigation is a **Minor** finding but still a real bug.

## Section 3 — Text Normalization (TTS Readability)

- [ ] Confirm displayText is never altered from clean, standard formatting —
      any TTS-friendly rewriting must only happen in speechText/SSML. If
      normalization has leaked into the visible UI (e.g. screen shows
      "Number 3" instead of "3."), this is a **Major** finding — it degrades
      the reading experience for sighted and low-vision users to accommodate
      TTS.
- [ ] Spot-check normalization against the app's actual finalized rules
      (documented separately): slash handling (acronym/path → "slash",
      word-pair → "or"), URLs → "a web link" placeholder (or clean domain
      name only when the URL itself is the spoken content), code snippets
      (~8 words / one line threshold: literal vs. placeholder), unit
      abbreviations left to Polly's native handling unless a specific
      mispronunciation has been found and documented.
- [ ] Listen to (or review the SSML output for) a real lesson containing
      numbers, a bulleted list, at least one abbreviation, and a heading.
      Confirm it reads naturally — no raw symbol gibberish, no unnatural
      pauses, no skipped content that changes meaning.
- [ ] Confirm bullet/list markers are dropped from speech (not read aloud as
      "bullet point" or "dash" for every item) while remaining visually
      present in displayText.

## Section 4 — Voice Command System

- [ ] Confirm the mic button never triggers processing while the user is
      still speaking — recording must fully complete (via silence detection
      or manual stop) before any transcription or intent parsing begins.
      Verify by checking logs/timestamps for overlap between "recording
      stopped" and "processing started."
- [ ] Confirm the voice command overlay does not navigate to a new route —
      it must overlay the current screen and dismiss back to the exact same
      state. Any `Navigator.push` in this flow is a **Major** finding, since
      it breaks the user's expected "quick command" mental model.
- [ ] Confirm the listening → processing transition is marked by both a
      visual change AND a non-visual cue (earcon or TTS). A visual-only
      transition is a **Blocker** for this app's primary user base — a
      blind user has no way to know the app has stopped listening.
- [ ] Rapid double-tapping the mic FAB never starts overlapping recording or
      processing sessions. This is the same bug class that previously
      caused app crashes — verify explicitly, don't assume it's fixed
      because the crash symptom is gone.
- [ ] Confirm the full fallback chain is intact and each link is reachable:
      LLM parse (Qwen/fllama) → fuzzy match fallback (CommandInterpreter) →
      spoken "I didn't catch that" fallback. Force a malformed/low-confidence
      result and confirm it degrades gracefully rather than hanging or
      failing silently.
- [ ] Confirm no voice command path can submit sensitive data (passwords,
      personal info) or bypass authentication — voice may only navigate to
      auth screens, never submit credentials directly.
- [ ] Confirm the fllama/Qwen model has a bounded lifecycle: not
      reloaded on every single command (latency cost), not left resident
      indefinitely with no idle-timeout disposal (memory cost), and never
      loaded/disposed concurrently from two different trigger points
      (crash risk).
- [ ] Confirm microphone and speech-recognition permissions are fully
      resolved (explicitly checked as granted) before any mic/recording API
      is invoked — a permission race is the most common cause of
      immediate-and-repeatable crashes on mic tap.

## Section 5 — Font Scaling & Visual Accessibility

- [ ] Font scale is applied globally via `MediaQuery` / `TextScaler` in the
      app's root builder, not per-widget — spot check a few random screens
      to confirm none hardcode a font size that ignores the global scale.
- [ ] Test the UI at the maximum supported scale (e.g. 2.0x) on at least one
      text-dense screen and one form/input screen — confirm text doesn't
      clip, truncate unexpectedly, or cause overlapping elements. Any
      layout that hardcodes fixed-height containers around text is a likely
      failure point — check for `Flexible`/`Wrap` usage.
- [ ] Color contrast meets WCAG AA (4.5:1 for normal text, 3:1 for large
      text) across primary UI surfaces, not just the highlighter — check
      button text, form labels, and status/error text specifically, since
      these are commonly overlooked.
- [ ] Confirm the app respects system-level accessibility settings where
      relevant (e.g. reduced motion, system font scale as a starting
      default) rather than only offering an in-app-only override.

## Section 6 — Screen Reader Compatibility (TalkBack / VoiceOver)

- [ ] Every interactive element (buttons, FAB, sliders, list items) has a
      meaningful `Semantics`/`accessibilityLabel` — spot check the mic FAB,
      playback controls, and settings toggles specifically, since these
      carry the most functional weight.
- [ ] Confirm there's a way for the user to disable the app's own TTS
      narration when they're already using a system screen reader
      (TalkBack/VoiceOver) — double narration (system reader + app TTS both
      speaking) is a **Major** usability failure, not a nice-to-have toggle.
- [ ] Focus order for screen reader navigation follows a logical reading
      order on at least the two or three most-used screens (dashboard,
      lesson reader, voice command overlay) — check this by actually
      enabling TalkBack/VoiceOver and navigating by swipe, not by reading
      the widget tree.
- [ ] Custom widgets (non-standard buttons, custom sliders, the highlighter
      text view) are wrapped with explicit `Semantics` rather than relying
      on default widget behavior, which often produces no label at all for
      custom-painted UI.

## Section 7 — Error Handling & Failure Modes

- [ ] Every failure point identified above (permission denied, model load
      failure, network failure fetching audio/speech marks, malformed LLM
      output, STT returning empty) results in a **spoken and/or visible
      message**, never a silent failure or an uncaught crash. This is the
      single most important cross-cutting rule in this entire audit — flag
      any silent-failure path found anywhere as a **Blocker**, regardless of
      which section it technically belongs to.
- [ ] Confirm there is no code path where the app appears to "hang" with no
      feedback for more than ~3-5 seconds (loading a model, fetching audio,
      waiting on LLM inference) without some indication — spinner AND/OR
      spoken "please wait," not one without the other.
- [ ] Confirm crash recovery: if the app crashed once during voice command
      use, does closing and reopening produce a clean state, or does bad
      persisted state (cached model reference, stuck flag in
      SharedPreferences) cause an immediate repeat crash? Test explicitly.

## Section 8 — Overall Readiness Assessment

After completing Sections 1–7, produce a summary report with:

1. **Blocker count and list** — anything that makes a core accessibility
   flow (reading a lesson, using voice commands, adjusting playback) fail
   silently, crash, or actively mislead a user who cannot see the screen.
   The app is NOT ready to present as an accessible app with any open
   Blocker.
2. **Major count and list** — real usability failures that degrade the
   experience significantly but have a workaround or don't cause total
   failure.
3. **Minor count and list** — polish issues, inconsistencies, edge cases.
4. **A plain-language readiness verdict**: not ready / ready with caveats /
   ready — based strictly on Blocker count (zero Blockers required for
   "ready"), not on overall polish or feature completeness.
5. For each Blocker and Major finding, state: which section/file it's in,
   why it fails specifically for a blind or low-vision user (not just "this
   is a bug"), and a one-line recommended fix direction — full fix
   implementation happens after this report is reviewed, not within it.

## Severity Guide

- **Blocker**: Silent failure, crash, or an accessibility feature that
  appears to work but doesn't (e.g. a non-functional pitch slider, a
  highlighter that points at the wrong word, a listening state with no
  non-visual indicator). These fail the app's core purpose for its primary
  users.
- **Major**: Confusing or degraded experience with a workaround (e.g. double
  narration from app TTS + system screen reader, a setting that requires an
  extra step to take effect).
- **Minor**: Cosmetic, edge-case, or affects a small subset of content/users
  without breaking core functionality.

## Notes for the agent running this skill

- Do not assume any previous fix is complete just because a related PR or
  commit exists — re-verify against the checklist directly in the current
  codebase state.
- If a section's relevant code cannot be found at all (e.g. no
  Semantics-related code found anywhere), that is itself a finding — report
  "not implemented" rather than skipping the section silently.
- Where this skill references specific architectural decisions (PlaybackState
  enum values, the SpeechEngine abstraction, Speech Marks, the alignment
  mapping), treat deviations from these patterns as worth flagging even if
  functionally the deviation "works" — consistency here is what prevents the
  next feature from reintroducing a bug class that was already solved once.
