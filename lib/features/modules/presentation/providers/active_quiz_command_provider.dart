import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizCommand {
  final String action;
  final String? target;
  final DateTime timestamp;

  QuizCommand(this.action, {this.target}) : timestamp = DateTime.now();
}

class ActiveQuizCommandNotifier extends Notifier<QuizCommand?> {
  @override
  QuizCommand? build() => null;

  void setCommand(QuizCommand command) {
    state = command;
  }
}

final activeQuizCommandProvider = NotifierProvider<ActiveQuizCommandNotifier, QuizCommand?>(
  ActiveQuizCommandNotifier.new,
);
