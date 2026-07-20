import 'package:flutter/material.dart';
import 'unified_tts_controller.dart';

class SmartAudioReaderScreen extends StatefulWidget {
  final String textToRead = "Welcome to InclusiveEd. This application automatically evaluated your device hardware to select the best reading voice, but you can use the switch above to change engines at any time.";

  const SmartAudioReaderScreen({super.key});

  @override
  State<SmartAudioReaderScreen> createState() => _SmartAudioReaderScreenState();
}

class _SmartAudioReaderScreenState extends State<SmartAudioReaderScreen> {
  final UnifiedTtsController _ttsController = UnifiedTtsController();
  
  int _highlightStart = 0;
  int _highlightEnd = 0;
  bool _isPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    await _ttsController.initialize();
    
    // Wire up the highlighting listener
    _ttsController.onProgressUpdate = (start, end) {
      if (mounted) {
        setState(() {
          _highlightStart = start;
          _highlightEnd = end;
        });
      }
    };

    // Listen for controller state changes (like engine switching or play state)
    _ttsController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  List<TextSpan> _buildHighlightedText() {
    if (!_ttsController.isPlaying || _highlightEnd == 0) {
      return [TextSpan(text: widget.textToRead, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))];
    }

    // Safety check for indices
    int hStart = _highlightStart.clamp(0, widget.textToRead.length);
    int hEnd = _highlightEnd.clamp(0, widget.textToRead.length);
    
    if (hStart > hEnd) hEnd = hStart;

    String beforeText = widget.textToRead.substring(0, hStart);
    String activeWord = widget.textToRead.substring(hStart, hEnd);
    String afterText = widget.textToRead.substring(hEnd);

    return [
      TextSpan(text: beforeText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      TextSpan(
        text: activeWord,
        style: TextStyle(
          color: Colors.black,
          backgroundColor: const Color(0xFFFDE047), // Yellow accessibility highlight
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(text: afterText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    ];
  }

  void _skipWords(int wordCount) {
    final text = widget.textToRead;
    if (text.isEmpty) return;

    // Split text into words to locate indices
    final words = text.substring(_highlightStart).split(RegExp(r'\s+'));
    if (wordCount > 0) {
      // Forward
      if (words.length <= wordCount) {
        _ttsController.stop();
        setState(() {
          _highlightStart = 0;
          _highlightEnd = 0;
        });
        return;
      }
      int charsToSkip = 0;
      for (int i = 0; i < wordCount; i++) {
        charsToSkip += words[i].length + 1; // word + space
      }
      final newStart = (_highlightStart + charsToSkip).clamp(0, text.length);
      setState(() {
        _highlightStart = newStart;
        _highlightEnd = newStart;
      });
      if (_ttsController.isPlaying) {
        _ttsController.stop();
        _ttsController.speak(text.substring(newStart));
      }
    } else {
      // Backward: Skip backward by counting words behind _highlightStart
      final beforeText = text.substring(0, _highlightStart);
      final wordsBefore = beforeText.split(RegExp(r'\s+'));
      int targetCount = wordsBefore.length + wordCount; // wordCount is negative
      if (targetCount <= 0) {
        setState(() {
          _highlightStart = 0;
          _highlightEnd = 0;
        });
        if (_ttsController.isPlaying) {
          _ttsController.stop();
          _ttsController.speak(text);
        }
        return;
      }
      int newStart = 0;
      for (int i = 0; i < targetCount; i++) {
        newStart += wordsBefore[i].length + 1;
      }
      newStart = newStart.clamp(0, text.length);
      setState(() {
        _highlightStart = newStart;
        _highlightEnd = newStart;
      });
      if (_ttsController.isPlaying) {
        _ttsController.stop();
        _ttsController.speak(text.substring(newStart));
      }
    }
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Accessible Reader"),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reading Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 22, height: 1.6),
                    children: _buildHighlightedText(),
                  ),
                ),
              ),
            ),

            // Expandable Persistent Control Drawer / Bottom Sheet
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle that toggles expansion on tap
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPanelExpanded = !_isPanelExpanded;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Collapsed Primary Media Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Skip backward 30 words
                      IconButton(
                        onPressed: () => _skipWords(-30),
                        icon: Icon(Icons.replay_30),
                        iconSize: 36,
                        color: theme.colorScheme.primary,
                        tooltip: "Skip backward 30 words",
                      ),

                      // Circle Play/Stop Button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _ttsController.isPlaying 
                              ? theme.colorScheme.errorContainer 
                              : theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_ttsController.isPlaying) {
                              _ttsController.stop();
                            } else {
                              _ttsController.speak(widget.textToRead.substring(_highlightStart));
                            }
                          },
                          icon: Icon(
                            _ttsController.isPlaying ? Icons.stop : Icons.play_arrow,
                            color: _ttsController.isPlaying 
                                ? theme.colorScheme.onErrorContainer 
                                : theme.colorScheme.onPrimaryContainer,
                            size: 32,
                          ),
                        ),
                      ),

                      // Skip forward 30 words
                      IconButton(
                        onPressed: () => _skipWords(30),
                        icon: Icon(Icons.forward_30),
                        iconSize: 36,
                        color: theme.colorScheme.primary,
                        tooltip: "Skip forward 30 words",
                      ),
                    ],
                  ),

                  // Expanded settings
                  if (_isPanelExpanded) ...[
                    SizedBox(height: 16),
                    const Divider(),
                    SizedBox(height: 12),

                    // Engine Selection Row
                    // Removed because Kokoro AI is deleted

                    // Speech rate (speed)
                    _buildSettingSlider(
                      title: "Speech Rate",
                      value: _ttsController.rate,
                      min: 0.1,
                      max: 1.0,
                      icon: Icons.speed,
                      onChanged: (val) => _ttsController.setRate(val),
                      displayValue: "${(val) => val.toStringAsFixed(1)}", // Handle dynamic
                      formatValue: (val) => "${(val * 2.0).toStringAsFixed(1)}x",
                    ),

                    // Speech pitch
                    _buildSettingSlider(
                      title: "Speech Pitch",
                      value: _ttsController.pitch,
                      min: 0.5,
                      max: 2.0,
                      icon: Icons.music_note,
                      onChanged: (val) => _ttsController.setPitch(val),
                      displayValue: "",
                      formatValue: (val) => val.toStringAsFixed(1),
                    ),

                    // Volume
                    _buildSettingSlider(
                      title: "Speech Volume",
                      value: _ttsController.volume,
                      min: 0.0,
                      max: 1.0,
                      icon: Icons.volume_up,
                      onChanged: (val) => _ttsController.setVolume(val),
                      displayValue: "",
                      formatValue: (val) => "${(val * 100).toInt()}%",
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
    required String displayValue,
    required String Function(double) formatValue,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text(title, style: theme.textTheme.bodyMedium),
                ],
              ),
              Text(
                formatValue(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
