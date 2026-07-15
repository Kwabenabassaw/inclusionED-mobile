import 'package:string_similarity/string_similarity.dart';

class Intent {
  final String type;
  final List<String> triggers;
  Intent(this.type, this.triggers);
}

class CommandInterpreter {
  final List<Intent> _intents = [
    Intent('login', ['log in', 'log me in', 'sign in']),
    Intent('readPage', ['read this page', 'read this week', 'read out loud', 'read screen']),
    Intent('goBack', ['go back', 'back', 'previous page', 'return']),
    Intent('openWeek', ['open week', 'go to week', 'navigate to week']),
    Intent('openCourse', ['open course', 'go to course', 'open class', 'go to class']),
    Intent('openCourses', ['open courses', 'go to courses', 'show courses']),
    Intent('openDashboard', ['open dashboard', 'go to home', 'go home', 'home screen', 'show dashboard']),
    Intent('openCalendar', ['open calendar', 'show my calendar', 'go to calendar', 'my calendar']),
    Intent('openNotifications', ['open notifications', 'show alerts', 'go to notifications', 'alerts', 'my notifications']),
    Intent('openProfile', ['open profile', 'go to my profile', 'my profile', 'show profile']),
    Intent('openVoiceSettings', ['open voice settings', 'change voice', 'voice settings', 'tts settings']),
    Intent('openSmartReader', ['open smart reader', 'open accessible reader', 'audio reader', 'smart reader']),
    Intent('enableDarkMode', ['turn on dark mode', 'enable dark mode', 'dark mode on', 'switch to dark mode']),
    Intent('disableDarkMode', ['turn off dark mode', 'disable dark mode', 'light mode', 'turn on light mode', 'enable light mode']),
    Intent('enableHighContrast', ['turn on high contrast', 'enable high contrast', 'high contrast mode']),
    Intent('disableHighContrast', ['turn off high contrast', 'disable high contrast', 'normal contrast']),
    Intent('setSpeedFast', ['set voice speed to fast', 'fast voice', 'speak faster', 'increase voice speed']),
    Intent('setSpeedNormal', ['set voice speed to normal', 'normal voice', 'speak normal']),
    Intent('setSpeedSlow', ['set voice speed to slow', 'slow voice', 'speak slower', 'decrease voice speed']),
    Intent('pauseReading', ['pause reading', 'pause', 'stop reading', 'halt']),
    Intent('resumeReading', ['resume reading', 'play', 'continue reading', 'start reading']),
    Intent('increaseTextSize', ['make text larger', 'increase text size', 'zoom in', 'larger text', 'bigger text']),
    Intent('decreaseTextSize', ['make text smaller', 'decrease text size', 'zoom out', 'smaller text']),
    Intent('presetDyslexia', ['turn on dyslexia mode', 'dyslexia mode', 'dyslexic font']),
    Intent('presetVisual', ['turn on visual impairment mode', 'visual mode', 'large text mode']),
    Intent('presetMotor', ['turn on motor difficulty mode', 'motor mode']),
    Intent('presetStandard', ['standard mode', 'reset accessibility', 'default settings', 'normal mode']),
    Intent('readScheduleToday', ['what do i have today', 'what is my schedule today', 'read my schedule for today', 'do i have class today', 'my schedule today']),
    Intent('readScheduleTomorrow', ['what do i have tomorrow', 'what is my schedule tomorrow', 'read my schedule for tomorrow', 'do i have class tomorrow', 'my schedule tomorrow']),
    Intent('continueLearning', ['continue learning', 'resume course', 'resume learning', 'pick up where i left off']),
    Intent('nextLesson', ['next lesson', 'go to next lesson', 'advance course', 'next module', 'continue to next']),
    Intent('previousLesson', ['previous lesson', 'go to previous lesson', 'go back in course', 'previous module']),
    Intent('explainLesson', ['explain this lesson', 'summarize this lesson', 'what is this lesson about', 'explain this to me']),
    Intent('askAI', ['ask ai', 'ask assistant', 'question for ai', 'ask the ai']),
    Intent('quizMe', ['quiz me', 'quiz me on this', 'test my knowledge', 'give me a quiz']),
    Intent('stopSpeaking', ['stop speaking', 'cancel tts', 'shut up', 'stop reading', 'be quiet']),
    Intent('repeatThat', ['repeat that', 'say that again', 'replay', 'repeat', 'read that again']),
    Intent('readSlower', ['read slower', 'speak slower', 'decrease speed', 'slow down']),
    Intent('readFaster', ['read faster', 'speak faster', 'increase speed', 'speed up']),
    Intent('openSettings', ['open settings', 'go to settings', 'show settings', 'settings screen']),
    Intent('search', ['search for', 'find', 'search']),
    Intent('help', ['help', 'help me', 'how do i use this', 'what can i say', 'i need help']),
    Intent('logout', ['logout', 'sign out', 'log me out']),
    Intent('whatsNext', ['what is next', 'whats next', 'upcoming event', 'what am i doing next']),
    Intent('clearNotifications', ['clear notifications', 'dismiss alerts', 'mark all as read', 'clear my notifications']),
    Intent('startQuiz', ['start quiz', 'begin assessment', 'take quiz', 'begin quiz']),
    Intent('selectOption', ['select option', 'choose option', 'select', 'choose']),
    Intent('submitQuiz', ['submit quiz', 'finish assessment', 'submit answers', 'finish quiz']),
    Intent('downloadCourse', ['download this course', 'make course offline', 'save for offline', 'download course']),
  ];

  /// Parses the transcript using fuzzy string matching and normalizes numbers.
  Map<String, dynamic>? parse(String transcript) {
    if (transcript.isEmpty) return null;

    // 1. Normalize string: lowercase, strip fillers
    String normalized = transcript.toLowerCase()
        .replaceAll(RegExp(r'\b(please|can you|um|uh)\b'), '')
        .trim();
        
    // 2. Normalize spoken numbers to digits for parsing
    const numberMap = {
      'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
      'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10'
    };
    numberMap.forEach((word, digit) {
      normalized = normalized.replaceAll(word, digit);
    });

    String? matchedType;
    double bestScore = 0.0;
    
    // 3. Fuzzy match against intents
    for (final intent in _intents) {
      for (final trigger in intent.triggers) {
        final score = trigger.similarityTo(normalized);
        if (score > bestScore && score > 0.65) { // 65% fuzzy threshold
          bestScore = score;
          matchedType = intent.type;
        }
      }
    }

    if (matchedType == null) {
      // Fallback for "open [something]" or "go to [something]"
      final match = RegExp(r'^(open|go to|navigate to)\s+(.+)').firstMatch(normalized);
      if (match != null) {
        String target = match.group(2)!
            .replaceAll(RegExp(r'\b(the|course|courses|class|classes)\b'), '')
            .trim();
        if (target.isNotEmpty) {
          return {'action': 'openCourse', 'target': target, 'confidence': 'medium'};
        }
      }
      return null; // Falls through to TTS fallback
    }

    // 4. Extract parameters if needed
    if (matchedType == 'openWeek') {
      final digitMatch = RegExp(r'\d+').firstMatch(normalized);
      if (digitMatch != null) {
        return {'action': matchedType, 'target': digitMatch.group(0), 'confidence': 'high'};
      } else {
        // If they said "open week" but no number was found, it might be incomplete
        return null;
      }
    }
    
    if (matchedType == 'openCourse') {
      String target = normalized
          .replaceAll(RegExp(r'\b(open|go to|navigate to|show|course|courses|class|classes)\b'), '')
          .trim();
      if (target.isNotEmpty) {
        return {'action': matchedType, 'target': target, 'confidence': 'high'};
      }
      return {'action': 'openCourses', 'confidence': 'high'};
    }

    if (matchedType == 'askAI') {
      String target = normalized.replaceAll(RegExp(r'\b(ask ai|ask assistant|question for ai|ask the ai)\b'), '').trim();
      if (target.isNotEmpty) {
        return {'action': matchedType, 'target': target, 'confidence': 'high'};
      }
    }

    if (matchedType == 'search') {
      String target = normalized.replaceAll(RegExp(r'\b(search for|find|search)\b'), '').trim();
      if (target.isNotEmpty) {
        return {'action': matchedType, 'target': target, 'confidence': 'high'};
      }
    }

    if (matchedType == 'selectOption') {
      // Look for a single letter a, b, c, or d
      final match = RegExp(r'\b([a-d]|1|2|3|4)\b').firstMatch(normalized);
      if (match != null) {
        String option = match.group(1)!;
        // Normalize 1234 to abcd
        if (option == '1') option = 'a';
        if (option == '2') option = 'b';
        if (option == '3') option = 'c';
        if (option == '4') option = 'd';
        return {'action': matchedType, 'target': option, 'confidence': 'high'};
      }
    }

    return {'action': matchedType, 'confidence': 'high'};
  }
}
