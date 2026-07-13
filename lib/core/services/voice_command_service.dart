import 'package:opencampus_lms/core/services/intent/command_interpreter.dart';

class VoiceCommandResult {
  final String action;
  final String? target;
  
  VoiceCommandResult({required this.action, this.target});
}

class VoiceCommandService {
  final CommandInterpreter _interpreter = CommandInterpreter();

  Future<VoiceCommandResult?> processCommand(String spokenText) async {
    final result = _interpreter.parse(spokenText);
    if (result != null) {
      return VoiceCommandResult(
        action: result['action'],
        target: result['target'],
      );
    }
    return null;
  }
}
