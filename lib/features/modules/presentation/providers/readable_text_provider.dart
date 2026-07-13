

import 'package:flutter_riverpod/legacy.dart';

/// Holds the text content of the currently active learning flow page
/// so that the global Audio Dock can read it using TTS.
final currentReadableTextProvider = StateProvider<String>((ref) => '');
