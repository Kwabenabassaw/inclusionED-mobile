import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/quiz.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/enrollment.dart';
import 'package:opencampus_lms/features/modules/presentation/quiz_results_screen.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/accessibility/presentation/display_settings_bottom_sheet.dart';

// ─── Riverpod State Management for Voice ──────────────────────────────────────

class QuizVoiceState {
  final bool isListening;
  final String lastWords;
  final bool isSpeechEnabled;
  final String? errorMessage;

  QuizVoiceState({
    this.isListening = false,
    this.lastWords = '',
    this.isSpeechEnabled = false,
    this.errorMessage,
  });

  QuizVoiceState copyWith({
    bool? isListening,
    String? lastWords,
    bool? isSpeechEnabled,
    String? errorMessage,
  }) {
    return QuizVoiceState(
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      isSpeechEnabled: isSpeechEnabled ?? this.isSpeechEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QuizVoiceController extends Notifier<QuizVoiceState> {
  final SpeechToText _speechToText = SpeechToText();

  @override
  QuizVoiceState build() {
    _initSpeech();
    return QuizVoiceState();
  }

  Future<void> _initSpeech() async {
    try {
      final enabled = await _speechToText.initialize(
        onError: (val) {
          state = state.copyWith(
            isListening: false,
            errorMessage: val.errorMsg,
          );
        },
        onStatus: (val) {
          if (val == 'notListening' || val == 'done') {
            state = state.copyWith(isListening: false);
          }
        },
      );
      state = state.copyWith(isSpeechEnabled: enabled);
    } catch (e) {
      state = state.copyWith(
          isSpeechEnabled: false, errorMessage: e.toString());
    }
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!state.isSpeechEnabled) {
      state = state.copyWith(errorMessage: 'Speech to text is not enabled.');
      return;
    }
    state = state.copyWith(isListening: true, lastWords: '', errorMessage: null);
    HapticFeedback.heavyImpact();

    try {
      await _speechToText.listen(
        onResult: (result) {
          state = state.copyWith(lastWords: result.recognizedWords);
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
            stopListening();
          }
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      state = state.copyWith(isListening: false, errorMessage: e.toString());
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    state = state.copyWith(isListening: false);
    HapticFeedback.mediumImpact();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final quizVoiceControllerProvider =
    NotifierProvider<QuizVoiceController, QuizVoiceState>(() {
  return QuizVoiceController();
});

// ─── Quiz Screen ──────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerStatefulWidget {
  final String courseId;
  final Quiz quiz;
  final bool embedded;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.quiz,
    this.embedded = false,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;

  Map<int, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  Timer? _timer;
  int _timeRemainingSeconds = 0;

  // Accessibility State
  final UnifiedTtsController _ttsController = UnifiedTtsController();
  double get _fontScaleMultiplier => ref.watch(accessibilityProvider).textScale;
  
  // Highlight tracking
  int _highlightStart = 0;
  int _highlightEnd = 0;
  int _questionOffsetStart = 0;
  int _questionOffsetEnd = 0;
  List<int> _optionOffsetStarts = [];
  List<int> _optionOffsetEnds = [];

  // Mic pulse animation
  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initTts();

    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    if (widget.quiz.timeLimit > 0) {
      _timeRemainingSeconds = widget.quiz.timeLimit * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingSeconds > 0) {
        setState(() => _timeRemainingSeconds--);
        if (_timeRemainingSeconds == 60) {
          _ttsController.speak('One minute remaining.');
        } else if (_timeRemainingSeconds == 10) {
          _ttsController.speak('Ten seconds left.');
        }
      } else {
        _timer?.cancel();
        _submitQuiz(autoSubmit: true);
      }
    });
  }

  Future<void> _initTts() async {
    await _ttsController.initialize();
    _ttsController.onProgressUpdate = (start, end) {
      if (mounted) {
        setState(() {
          _highlightStart = start;
          _highlightEnd = end;
        });
      }
    };
    _ttsController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _ttsController.stop();
    _ttsController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  // ─── Voice Input Handling ───────────────────────────────────────────────────

  void _handleVoiceInput(String voiceText) {
    if (voiceText.isEmpty) return;

    final lower = voiceText.toLowerCase().trim();

    // 1. Check for navigation commands
    if (_isNextCommand(lower)) {
      _voiceNextQuestion();
      return;
    }
    if (_isPreviousCommand(lower)) {
      _voicePreviousQuestion();
      return;
    }
    if (_isSubmitCommand(lower)) {
      _submitQuiz();
      return;
    }
    if (_isChangeCommand(lower)) {
      setState(() => _selectedAnswers.remove(_currentQuestionIndex));
      _ttsController.speak('Answer cleared. Tap the mic to answer again.');
      return;
    }
    if (_isPlayCommand(lower)) {
      _playQuestionAudio(widget.quiz.questions[_currentQuestionIndex], forcePlay: true);
      return;
    }

    // 2. Try to match as an answer to the current question
    _matchVoiceToAnswer(voiceText);
  }

  bool _isNextCommand(String lower) =>
      lower.contains('next') ||
      lower == 'continue' ||
      lower == 'proceed' ||
      lower == 'move on';

  bool _isPreviousCommand(String lower) =>
      lower.contains('previous') ||
      lower.contains('go back') ||
      lower == 'back';

  bool _isSubmitCommand(String lower) =>
      lower.contains('submit') ||
      lower.contains('finish') ||
      lower.contains('done');

  bool _isChangeCommand(String lower) =>
      lower.contains('change') ||
      lower.contains('re-answer') ||
      lower.contains('reanswer') ||
      lower == 'clear' ||
      lower == 'redo';

  bool _isPlayCommand(String lower) =>
      lower.contains('play') ||
      lower.contains('read') ||
      lower.contains('speak');

  void _voiceNextQuestion() {
    final hasAnswer =
        _selectedAnswers[_currentQuestionIndex]?.isNotEmpty == true;
    if (!hasAnswer) {
      _ttsController.speak('Please select an answer first.');
      return;
    }
    _nextQuestion();
  }

  void _voicePreviousQuestion() {
    _previousQuestion();
  }

  void _matchVoiceToAnswer(String voiceText) {
    final question = widget.quiz.questions[_currentQuestionIndex];
    final type = question.type.toUpperCase().replaceAll('-', '_');
    final lower = voiceText.toLowerCase().trim();

    if (type == 'MULTIPLE_CHOICE') {
      final options = question.options ?? [];
      String? matched = _matchMultipleChoice(lower, options);

      if (matched != null) {
        setState(() => _selectedAnswers[_currentQuestionIndex] = matched);
        _announceSelection(matched);
      } else {
        _ttsController.speak(
          "I didn't catch that. Please tap the mic and say a letter like A, B, C, or repeat the option.",
        );
      }
    } else if (type == 'TRUE_FALSE') {
      String? matched;
      if (lower.contains('true') || lower == 'yes') {
        matched = 'True';
      } else if (lower.contains('false') || lower == 'no') {
        matched = 'False';
      }

      if (matched != null) {
        final finalMatch = matched;
        setState(() => _selectedAnswers[_currentQuestionIndex] = finalMatch);
        _announceSelection(finalMatch);
      } else {
        _ttsController.speak('Please tap the mic and say true or false.');
      }
    } else {
      // short-answer / fill-blank: just transcribe
      setState(() => _selectedAnswers[_currentQuestionIndex] = voiceText);
      _ttsController.speak('Recorded: $voiceText.');
    }
  }

  String? _matchMultipleChoice(String lower, List<String> options) {
    if (options.isEmpty) return null;
    
    // Single letter match
    final maxLetter = String.fromCharCode('a'.codeUnitAt(0) + options.length - 1);
    final singleLetter = RegExp('^[a-$maxLetter]\$');
    if (singleLetter.hasMatch(lower)) {
      final idx = lower.codeUnitAt(0) - 'a'.codeUnitAt(0);
      if (idx < options.length) return options[idx];
    }

    // Ordinal match
    final ordinalMap = {
      'first': 0, 'one': 0, '1': 0,
      'second': 1, 'two': 1, '2': 1,
      'third': 2, 'three': 2, '3': 2,
      'fourth': 3, 'four': 3, '4': 3,
    };
    for (final entry in ordinalMap.entries) {
      if (lower.contains(entry.key) && entry.value < options.length) {
        return options[entry.value];
      }
    }

    // "Option A" match
    final letterPattern = RegExp(r'\b(option|letter|choice)\s+([a-d])\b');
    final letterMatch = letterPattern.firstMatch(lower);
    if (letterMatch != null) {
      final idx = letterMatch.group(2)!.codeUnitAt(0) - 'a'.codeUnitAt(0);
      if (idx < options.length) return options[idx];
    }

    // Fuzzy text match
    double bestScore = 0.4;
    String? bestMatch;
    for (final option in options) {
      final score = option.toLowerCase().similarityTo(lower);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = option;
      }
    }
    if (bestMatch != null) return bestMatch;

    // Partial substring match
    for (final option in options) {
      if (lower.contains(option.toLowerCase().substring(
            0,
            (option.length * 0.4).ceil().clamp(3, option.length),
          ))) {
        return option;
      }
    }

    return null;
  }

  void _announceSelection(String selectedOption) {
    final isLast = _currentQuestionIndex == widget.quiz.questions.length - 1;
    final confirmText = isLast
        ? 'Great! You selected $selectedOption. Tap mic and say submit to finish.'
        : 'Great! You selected $selectedOption. Tap mic and say next to continue.';

    _ttsController.speak(confirmText);
  }

  // ─── Play button ────────────────────────────────────────────────────────────

  void _playQuestionAudio(QuizQuestion question, {bool forcePlay = false}) {
    if (_ttsController.isPlaying && !forcePlay) {
      _ttsController.stop();
      setState(() {
        _highlightStart = 0;
        _highlightEnd = 0;
      });
    } else {
      if (_ttsController.isPlaying) _ttsController.stop();
      setState(() {
        _highlightStart = 0;
        _highlightEnd = 0;
        _questionOffsetStart = 0;
        _questionOffsetEnd = 0;
        _optionOffsetStarts.clear();
        _optionOffsetEnds.clear();
      });

      final buffer = StringBuffer();
      
      buffer.write('Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}. ');
      
      _questionOffsetStart = buffer.length;
      buffer.write(question.ttsReadout ?? question.text);
      _questionOffsetEnd = buffer.length;

      final type = question.type.toUpperCase().replaceAll('-', '_');
      if (type == 'MULTIPLE_CHOICE' && question.options != null) {
        buffer.write(' Your options are: ');
        for (int i = 0; i < question.options!.length; i++) {
          final letter = String.fromCharCode(65 + i);
          buffer.write('Option $letter: ');
          _optionOffsetStarts.add(buffer.length);
          buffer.write(question.options![i]);
          _optionOffsetEnds.add(buffer.length);
          buffer.write('. ');
        }
      } else if (type == 'TRUE_FALSE') {
        buffer.write(' Is this true or false?');
        _optionOffsetStarts.add(_questionOffsetStart); // Provide dummy fallback if needed, or handle specially
        _optionOffsetEnds.add(_questionOffsetStart);
      }
      
      buffer.write(' Tap the microphone button at the bottom to answer.');
      _ttsController.speak(buffer.toString());
    }
    setState(() {});
  }

  // ─── Navigation & Submit ────────────────────────────────────────────────────

  void _nextQuestion() {
    setState(() {
      _highlightStart = 0;
      _highlightEnd = 0;
    });
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    setState(() {
      _highlightStart = 0;
      _highlightEnd = 0;
    });
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();
    ref.read(quizVoiceControllerProvider.notifier).stopListening();

    try {
      final enrollmentStream =
          ref.read(activeEnrollmentStreamProvider(widget.courseId).future);
      final enrollment = await enrollmentStream;

      if (enrollment != null) {
        final progress = enrollment.progress ?? const EnrollmentProgress();
        final updatedQuizIds = Set<String>.from(progress.completedQuizIds);
        updatedQuizIds.add(widget.quiz.id);

        await ref.read(courseRepositoryProvider).updateEnrollmentProgress(
              enrollment.id,
              progress.copyWith(completedQuizIds: updatedQuizIds.toList()),
            );

        int score = 0;
        final answersMap = <String, String>{};
        for (int i = 0; i < widget.quiz.questions.length; i++) {
          final q = widget.quiz.questions[i];
          final answer = _selectedAnswers[i] ?? '';
          answersMap[i.toString()] = answer;
          if (answer.toLowerCase().trim() ==
              q.correctAnswer.toLowerCase().trim()) {
            score += q.points;
          }
        }

        final timeSpentSeconds = widget.quiz.timeLimit > 0
            ? (widget.quiz.timeLimit * 60) - _timeRemainingSeconds
            : 0;

        await ref.read(courseRepositoryProvider).submitQuiz({
          'quizId': widget.quiz.id,
          'studentId': enrollment.studentId,
          'score': score,
          'answers': answersMap,
          'completedAt': DateTime.now().toIso8601String(),
          'timeSpentSeconds': timeSpentSeconds,
        });
      }

      if (!mounted) return;

      if (autoSubmit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Time is up! Quiz submitted automatically.')),
        );
      }

      final resultsScreen = QuizResultsScreen(
        courseId: widget.courseId,
        quiz: widget.quiz,
        studentAnswers: _selectedAnswers,
      );

      if (widget.embedded) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => resultsScreen),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => resultsScreen),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting quiz: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  // ─── Accessibility Settings ─────────────────────────────────────────────────

  void _showAccessibilitySettings() {
    showDisplaySettingsBottomSheet(context);
  }

  String get _formattedTime {
    final minutes = (_timeRemainingSeconds / 60).floor();
    final seconds = _timeRemainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: Text('No questions in this quiz.')),
      );
    }

    // Watch voice state to display errors via SnackBar if any
    ref.listen<QuizVoiceState>(quizVoiceControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech Error: ${next.errorMessage}')),
        );
        ref.read(quizVoiceControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(widget.quiz.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_accessibility),
                  tooltip: 'Accessibility Settings',
                  onPressed: _showAccessibilitySettings,
                ),
                if (widget.quiz.timeLimit > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.stackMd),
                    child: Center(
                      child: Semantics(
                        label: 'Time remaining: $_formattedTime',
                        child: Text(
                          _formattedTime,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                _timeRemainingSeconds < 60 ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
            semanticsLabel: 'Quiz progress',
            semanticsValue: '${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
          ),
          // Show what the mic is hearing at the top if listening
          Consumer(
            builder: (context, ref, child) {
              final voiceState = ref.watch(quizVoiceControllerProvider);
              if (!voiceState.isListening && voiceState.lastWords.isEmpty) return const SizedBox.shrink();
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Text(
                  voiceState.isListening 
                      ? (voiceState.lastWords.isEmpty ? 'Listening...' : voiceState.lastWords)
                      : 'Heard: "${voiceState.lastWords}"',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentQuestionIndex = index);
                _playQuestionAudio(widget.quiz.questions[index], forcePlay: true);
              },
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(
                    widget.quiz.questions[index], index);
              },
            ),
          ),
          _buildNavigationFooter(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 32,
              onPressed: () => _playQuestionAudio(widget.quiz.questions[_currentQuestionIndex]),
              icon: Icon(
                _ttsController.isPlaying
                    ? Icons.stop_circle
                    : Icons.play_circle_fill,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: _ttsController.isPlaying ? 'Stop' : 'Play',
            ),
          ),
          const SizedBox(width: 16),
          _buildCenterMicButton(),
        ],
      ),
    );
  }

  Widget _buildCenterMicButton() {
    return Consumer(
      builder: (context, ref, child) {
        final voiceState = ref.watch(quizVoiceControllerProvider);
        final isListening = voiceState.isListening;
        
        if (isListening) {
          _pulseAnimController.repeat(reverse: true);
        } else {
          _pulseAnimController.stop();
          _pulseAnimController.reset();
        }
        
        return AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: isListening ? _pulseAnim.value : 1.0,
              child: SizedBox(
                width: 80,
                height: 80,
                child: Semantics(
                  button: true,
                  label: isListening ? 'Stop Voice Input' : 'Start Voice Input',
                  child: FloatingActionButton(
                    onPressed: () {
                      // Stop any reading TTS so the mic isn't confused
                      if (_ttsController.isPlaying) {
                        _ttsController.stop();
                      }
                      if (isListening) {
                        ref.read(quizVoiceControllerProvider.notifier).stopListening();
                      } else {
                        ref.read(quizVoiceControllerProvider.notifier).startListening(
                          onResult: _handleVoiceInput,
                        );
                      }
                    },
                    backgroundColor: isListening 
                        ? Colors.red 
                        : Theme.of(context).colorScheme.primary,
                    elevation: isListening ? 8 : 4,
                    tooltip: isListening ? 'Stop Voice Input' : 'Start Voice Input',
                    shape: const CircleBorder(),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuestionPage(QuizQuestion question, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppDimensions.marginPage,
        right: AppDimensions.marginPage,
        top: AppDimensions.marginPage,
        bottom: 120, // Extra padding at bottom for the FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1} of ${widget.quiz.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
                textScaler: TextScaler.linear(_fontScaleMultiplier),
              ),
              Text(
                'Points: ${question.points}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textScaler: TextScaler.linear(_fontScaleMultiplier),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackMd),
          _buildHighlightedText(
            question.text,
            Theme.of(context).textTheme.headlineSmall ?? const TextStyle(),
            _questionOffsetStart,
            _questionOffsetEnd,
          ),
          if (question.altText != null && question.altText!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              '[Image Description: ${question.altText}]',
              style:
                  const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              textScaler: TextScaler.linear(_fontScaleMultiplier),
            ),
          ],
          const SizedBox(height: AppDimensions.stackXl),
          _buildInputForQuestionType(question, index),
        ],
      ),
    );
  }

  Widget _buildInputForQuestionType(QuizQuestion question, int index) {
    final answer = _selectedAnswers[index] ?? '';
    final type = question.type.toUpperCase().replaceAll('-', '_');

    if (type == 'MULTIPLE_CHOICE') {
      final options = question.options ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(options.length, (optIndex) {
          final optionText = options[optIndex];
          final isSelected = answer == optionText;
          final letter = String.fromCharCode(65 + optIndex);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.stackMd),
            child: _OptionButton(
              letter: letter,
              text: optionText,
              isSelected: isSelected,
              fontScaleMultiplier: _fontScaleMultiplier,
              onTap: () => setState(() => _selectedAnswers[index] = optionText),
              highlightStartOffset: optIndex < _optionOffsetStarts.length ? _optionOffsetStarts[optIndex] : 0,
              highlightEndOffset: optIndex < _optionOffsetEnds.length ? _optionOffsetEnds[optIndex] : 0,
              highlightStartGlobal: _highlightStart,
              highlightEndGlobal: _highlightEnd,
            ),
          );
        }),
      );
    } else if (type == 'TRUE_FALSE') {
      return Column(
        children: [
          _buildTrueFalseButton(index, answer, 'True', 0),
          const SizedBox(height: AppDimensions.stackMd),
          _buildTrueFalseButton(index, answer, 'False', 1),
        ],
      );
    } else {
      return Semantics(
        label: 'Short answer input',
        child: TextField(
          controller: TextEditingController(text: answer)
            ..selection = TextSelection.collapsed(offset: answer.length),
          onChanged: (val) => _selectedAnswers[index] = val,
          style: TextStyle(fontSize: 16 * _fontScaleMultiplier),
          decoration: InputDecoration(
            border: const OutlineInputBorder(borderSide: BorderSide(width: 2)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 3),
            ),
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: EdgeInsets.all(16 * _fontScaleMultiplier),
          ),
          maxLines: question.type == 'short-answer' ? 3 : 1,
        ),
      );
    }
  }

  Widget _buildTrueFalseButton(
      int questionIndex, String currentAnswer, String value, int optIndex) {
    final isSelected = currentAnswer == value;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Answer choice: $value',
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 3.0 : 1.0,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(AppDimensions.stackMd * _fontScaleMultiplier),
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () => setState(() => _selectedAnswers[questionIndex] = value),
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24 * _fontScaleMultiplier,
          ),
          SizedBox(width: 12 * _fontScaleMultiplier),
          _buildHighlightedText(
            value,
            TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            optIndex < _optionOffsetStarts.length ? _optionOffsetStarts[optIndex] : 0,
            optIndex < _optionOffsetEnds.length ? _optionOffsetEnds[optIndex] : 0,
          ),
        ],
      ),
    ));
  }

  Widget _buildHighlightedText(
      String text, TextStyle baseStyle, int localStart, int localEnd) {
    // No highlight: range is unset, or the global highlight doesn't overlap this text window
    final bool notActive = _highlightEnd <= _highlightStart ||
        _highlightEnd <= localStart ||
        _highlightStart >= localEnd ||
        (localStart == 0 && localEnd == 0);
    if (notActive) {
      return Text(text,
          style: baseStyle, textScaler: TextScaler.linear(_fontScaleMultiplier));
    }

    final int startHighlight =
        (_highlightStart - localStart).clamp(0, text.length);
    final int endHighlight = (_highlightEnd - localStart).clamp(0, text.length);

    if (startHighlight >= endHighlight) {
      return Text(text,
          style: baseStyle, textScaler: TextScaler.linear(_fontScaleMultiplier));
    }

    final beforeText = text.substring(0, startHighlight);
    final activeWord = text.substring(startHighlight, endHighlight);
    final afterText = text.substring(endHighlight);

    return RichText(
      textScaler: TextScaler.linear(_fontScaleMultiplier),
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: beforeText),
          TextSpan(
            text: activeWord,
            style: baseStyle.copyWith(
              color: Colors.black,
              backgroundColor: const Color(0xFFFDE047),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: afterText),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter() {
    final hasAnsweredCurrent =
        _selectedAnswers[_currentQuestionIndex]?.isNotEmpty == true;
    final isLastQuestion =
        _currentQuestionIndex == widget.quiz.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.marginPage),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
            child: const Text('Previous'),
          ),
          ElevatedButton(
            onPressed:
                hasAnsweredCurrent && !_isSubmitting ? _nextQuestion : null,
            child: _isSubmitting
                ? Semantics(
                    label: 'Submitting quiz',
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
          ),
        ],
      ),
    );
  }
}

// ─── Option Button Widget ──────────────────────────────────────────────────────

class _OptionButton extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final double fontScaleMultiplier;
  final VoidCallback onTap;
  final int highlightStartOffset;
  final int highlightEndOffset;
  final int highlightStartGlobal;
  final int highlightEndGlobal;

  const _OptionButton({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.fontScaleMultiplier,
    required this.onTap,
    this.highlightStartOffset = 0,
    this.highlightEndOffset = 0,
    this.highlightStartGlobal = 0,
    this.highlightEndGlobal = 0,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(_OptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _flashController.forward(from: 0).then((_) => _flashController.reverse());
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        final flashValue = _flashController.value;
        Color bgColor;
        if (flashValue > 0 && widget.isSelected) {
          bgColor = Color.lerp(
            theme.colorScheme.primaryContainer,
            Colors.green.shade200,
            flashValue,
          )!;
        } else {
          bgColor = widget.isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface;
        }

        return Semantics(
          button: true,
          selected: widget.isSelected,
          label: 'Answer choice: ${widget.text}',
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
            backgroundColor: bgColor,
            side: BorderSide(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: widget.isSelected ? 3.0 : 1.0,
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(
                AppDimensions.stackMd * widget.fontScaleMultiplier),
            minimumSize: const Size.fromHeight(60),
          ),
          onPressed: widget.onTap,
          child: Row(
            children: [
              Container(
                width: 32 * widget.fontScaleMultiplier,
                height: 32 * widget.fontScaleMultiplier,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.letter,
                  style: TextStyle(
                    color: widget.isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * widget.fontScaleMultiplier,
                  ),
                ),
              ),
              SizedBox(width: 12 * widget.fontScaleMultiplier),
              Expanded(
                child: _buildOptionHighlightedText(
                  widget.text,
                  TextStyle(
                    color: widget.isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20 * widget.fontScaleMultiplier,
                ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildOptionHighlightedText(String text, TextStyle baseStyle) {
    final bool notActive = widget.highlightEndGlobal <= widget.highlightStartGlobal ||
        widget.highlightEndGlobal <= widget.highlightStartOffset ||
        widget.highlightStartGlobal >= widget.highlightEndOffset ||
        (widget.highlightStartOffset == 0 && widget.highlightEndOffset == 0);
    if (notActive) {
      return Text(text,
          style: baseStyle, textScaler: TextScaler.linear(widget.fontScaleMultiplier));
    }

    final int startHighlight =
        (widget.highlightStartGlobal - widget.highlightStartOffset).clamp(0, text.length);
    final int endHighlight =
        (widget.highlightEndGlobal - widget.highlightStartOffset).clamp(0, text.length);

    if (startHighlight >= endHighlight) {
      return Text(text,
          style: baseStyle, textScaler: TextScaler.linear(widget.fontScaleMultiplier));
    }

    final beforeText = text.substring(0, startHighlight);
    final activeWord = text.substring(startHighlight, endHighlight);
    final afterText = text.substring(endHighlight);

    return RichText(
      textScaler: TextScaler.linear(widget.fontScaleMultiplier),
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: beforeText),
          TextSpan(
            text: activeWord,
            style: baseStyle.copyWith(
              color: Colors.black,
              backgroundColor: const Color(0xFFFDE047),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: afterText),
        ],
      ),
    );
  }
}
