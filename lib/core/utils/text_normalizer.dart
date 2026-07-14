class TextNormalizer {
  /// Cleans markdown characters from [rawText] for TTS reading.
  /// Returns both the [cleanText] (the text meant to be spoken) and an
  /// [indexMap] that maps an index in [cleanText] back to its original
  /// index in [rawText].
  static ({String cleanText, List<int> indexMap}) normalizeForSpeech(String rawText) {
    final StringBuffer cleanText = StringBuffer();
    final List<int> indexMap = [];

    for (int i = 0; i < rawText.length; i++) {
      final int codeUnit = rawText.codeUnitAt(i);
      // ASCII values: # (35), * (42), > (62), ` (96)
      if (codeUnit != 35 && codeUnit != 42 && codeUnit != 62 && codeUnit != 96) {
        cleanText.writeCharCode(codeUnit);
        indexMap.add(i);
      }
    }

    // Add a final mapping for the length to handle cases where start/end indices point to the end of the string
    if (indexMap.isNotEmpty) {
      indexMap.add(rawText.length);
    } else {
      indexMap.add(0);
    }

    return (cleanText: cleanText.toString(), indexMap: indexMap);
  }
}
