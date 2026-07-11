import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/shared/models/quiz.dart';
import 'package:inclusive_ed_student/features/courses/data/course_repository.dart';
import 'package:inclusive_ed_student/shared/models/enrollment.dart';
import 'package:inclusive_ed_student/features/modules/presentation/quiz_results_screen.dart';
import 'package:inclusive_ed_student/features/accessibility/unified_tts_controller.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String courseId;
  final Quiz quiz;
  final bool embedded;
  
  const QuizScreen({super.key, required this.courseId, required this.quiz, this.embedded = false});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  
  Map<int, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  Timer? _timer;
  int _timeRemainingSeconds = 0;

  // Accessibility State
  final UnifiedTtsController _ttsController = UnifiedTtsController();
  double _fontScaleMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _ttsController.initialize();
    
    if (widget.quiz.timeLimit > 0) {
      _timeRemainingSeconds = widget.quiz.timeLimit * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingSeconds > 0) {
        setState(() {
          _timeRemainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz(autoSubmit: true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _ttsController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    
    if (result.finalResult) {
      _matchVoiceToInput(_lastWords);
    }
  }
  
  void _matchVoiceToInput(String voiceText) {
    if (voiceText.isEmpty) return;
    
    final question = widget.quiz.questions[_currentQuestionIndex];
    final type = question.type.toUpperCase().replaceAll('-', '_');
    
    if (type == 'MULTIPLE_CHOICE' || type == 'TRUE_FALSE') {
      final options = type == 'TRUE_FALSE' ? ['True', 'False'] : (question.options ?? []);
      final lowerVoiceText = voiceText.toLowerCase();
      
      for (int i = 0; i < options.length; i++) {
        if (lowerVoiceText.contains(options[i].toLowerCase()) || 
            lowerVoiceText.contains('option ${i + 1}') ||
            lowerVoiceText.contains(String.fromCharCode(97 + i))) {
          setState(() {
            _selectedAnswers[_currentQuestionIndex] = options[i];
          });
          break;
        }
      }
    } else {
      // For short-answer and FILL_BLANK, just input the text
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = voiceText;
      });
    }
  }

  void _playAudio(QuizQuestion question) {
    if (_ttsController.isPlaying) {
      _ttsController.stop();
    } else {
      // Use the pre-generated SSML readout if available, else fallback to basic read
      final textToRead = question.ttsReadout ?? _buildFallbackTtsText(question);
      _ttsController.speak(textToRead);
    }
    // Update UI state so the play button can switch to stop icon
    setState(() {});
  }

  String _buildFallbackTtsText(QuizQuestion question) {
    final buffer = StringBuffer();
    buffer.writeln(question.text);
    if (question.options != null && question.options!.isNotEmpty) {
      buffer.writeln(" Options are: ");
      for (int i = 0; i < question.options!.length; i++) {
        buffer.writeln("Option ${String.fromCharCode(65 + i)}: ${question.options![i]}. ");
      }
    }
    return buffer.toString();
  }

  void _showAccessibilitySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.stackLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Accessibility Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  Row(
                    children: [
                      const Icon(Icons.text_format),
                      const SizedBox(width: AppDimensions.stackMd),
                      const Text('Text Size'),
                      Expanded(
                        child: Slider(
                          value: _fontScaleMultiplier,
                          min: 1.0,
                          max: 2.5,
                          divisions: 6,
                          label: '${_fontScaleMultiplier.toStringAsFixed(1)}x',
                          onChanged: (val) {
                            setModalState(() {
                              _fontScaleMultiplier = val;
                            });
                            setState(() {
                              _fontScaleMultiplier = val;
                            });
                          },
                        ),
                      ),
                      Text('${_fontScaleMultiplier.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();

    try {
      final enrollmentStream = ref.read(activeEnrollmentStreamProvider(widget.courseId).future);
      final enrollment = await enrollmentStream;

      if (enrollment != null) {
        final progress = enrollment.progress ?? const EnrollmentProgress();
        final updatedQuizIds = Set<String>.from(progress.completedQuizIds);
        updatedQuizIds.add(widget.quiz.id);

        await ref.read(courseRepositoryProvider).updateEnrollmentProgress(
          enrollment.id, 
          progress.copyWith(completedQuizIds: updatedQuizIds.toList()),
        );

        // Calculate score and submit
        int score = 0;
        final answersMap = <String, String>{};
        for (int i = 0; i < widget.quiz.questions.length; i++) {
          final q = widget.quiz.questions[i];
          final answer = _selectedAnswers[i] ?? '';
          answersMap[i.toString()] = answer;
          if (answer.toLowerCase().trim() == q.correctAnswer.toLowerCase().trim()) {
            score += q.points;
          }
        }

        final timeSpentSeconds = widget.quiz.timeLimit > 0 ? (widget.quiz.timeLimit * 60) - _timeRemainingSeconds : 0;

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
          const SnackBar(content: Text('Time is up! Quiz submitted automatically.')),
        );
      }

      if (widget.embedded) {
        // If embedded, we still go to results, but maybe wait 
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizResultsScreen(
              courseId: widget.courseId,
              quiz: widget.quiz,
              studentAnswers: _selectedAnswers,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultsScreen(
              courseId: widget.courseId,
              quiz: widget.quiz,
              studentAnswers: _selectedAnswers,
            ),
          ),
        );
      }
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting quiz: $e')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _nextQuestion() {
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
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String get _formattedTime {
    final minutes = (_timeRemainingSeconds / 60).floor();
    final seconds = _timeRemainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: Text('No questions in this quiz.')),
      );
    }

    return Scaffold(
      appBar: widget.embedded ? null : AppBar(
        title: Text(widget.quiz.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_accessibility),
            tooltip: 'Accessibility Settings',
            onPressed: _showAccessibilitySettings,
          ),
          if (widget.quiz.timeLimit > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.stackMd),
              child: Center(
                child: Text(
                  _formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _timeRemainingSeconds < 60 ? Colors.red : null,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              color: _speechToText.isListening ? Colors.red : null,
            ),
            tooltip: 'Dictate answer',
            onPressed: _speechEnabled
                ? (_speechToText.isNotListening ? _startListening : _stopListening)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Enforce button navigation
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                  _lastWords = '';
                });
              },
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(widget.quiz.questions[index], index);
              },
            ),
          ),
          _buildNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuizQuestion question, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.marginPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1} of ${widget.quiz.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
                textScaleFactor: _fontScaleMultiplier,
              ),
              Text(
                'Points: ${question.points}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textScaleFactor: _fontScaleMultiplier,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textScaleFactor: _fontScaleMultiplier,
                ),
              ),
              IconButton(
                onPressed: () => _playAudio(question),
                icon: Icon(
                  _ttsController.isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                  color: Theme.of(context).colorScheme.primary,
                  size: 36 * _fontScaleMultiplier,
                ),
                tooltip: _ttsController.isPlaying ? 'Stop Audio' : 'Play Question Aloud',
              ),
            ],
          ),
          if (question.altText != null && question.altText!.isNotEmpty) ...[
             const SizedBox(height: AppDimensions.stackSm),
             Text(
               '[Image Description: ${question.altText}]',
               style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
               textScaleFactor: _fontScaleMultiplier,
             ),
          ],
          const SizedBox(height: AppDimensions.stackXl),
          _buildInputForQuestionType(question, index),
          
          if (_speechToText.isListening) 
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.stackLg),
              child: Text(
                'Listening... $_lastWords', 
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                textScaleFactor: _fontScaleMultiplier,
              ),
            ),
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
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.stackMd),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  width: isSelected ? 3.0 : 1.0,
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(AppDimensions.stackMd * _fontScaleMultiplier),
                minimumSize: const Size.fromHeight(60), // Ensure robust touch target
              ),
              onPressed: () {
                setState(() {
                  _selectedAnswers[index] = optionText;
                });
              },
              child: Text(
                '${String.fromCharCode(65 + optIndex)}. $optionText',
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textScaleFactor: _fontScaleMultiplier,
              ),
            ),
          );
        }),
      );
    } else if (type == 'TRUE_FALSE') {
      return Column(
        children: [
          _buildTrueFalseButton(index, answer, 'True'),
          const SizedBox(height: AppDimensions.stackMd),
          _buildTrueFalseButton(index, answer, 'False'),
        ],
      );
    } else {
      // short-answer or FILL_BLANK
      return TextField(
        controller: TextEditingController(text: answer)
          ..selection = TextSelection.collapsed(offset: answer.length),
        onChanged: (val) {
          _selectedAnswers[index] = val;
        },
        style: TextStyle(fontSize: 16 * _fontScaleMultiplier),
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide(width: 2)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)),
          hintText: 'Type your answer here...',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding: EdgeInsets.all(16 * _fontScaleMultiplier),
        ),
        maxLines: question.type == 'short-answer' ? 3 : 1,
      );
    }
  }

  Widget _buildTrueFalseButton(int questionIndex, String currentAnswer, String value) {
    final isSelected = currentAnswer == value;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          width: isSelected ? 3.0 : 1.0,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(AppDimensions.stackMd * _fontScaleMultiplier),
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () {
        setState(() => _selectedAnswers[questionIndex] = value);
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24 * _fontScaleMultiplier,
          ),
          SizedBox(width: 12 * _fontScaleMultiplier),
          Text(
            value,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textScaleFactor: _fontScaleMultiplier,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter() {
    final hasAnsweredCurrent = _selectedAnswers[_currentQuestionIndex]?.isNotEmpty == true;
    final isLastQuestion = _currentQuestionIndex == widget.quiz.questions.length - 1;

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
            onPressed: hasAnsweredCurrent && !_isSubmitting ? _nextQuestion : null,
            child: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
          ),
        ],
      ),
    );
  }
}
