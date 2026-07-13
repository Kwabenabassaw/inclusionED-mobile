import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:opencampus_lms/core/services/stt_service.dart';

class AccessibleDictationField extends StatefulWidget {
  final Function(String) onTextChanged;
  final String semanticLabel;

  const AccessibleDictationField({
    super.key,
    required this.onTextChanged,
    required this.semanticLabel,
  });

  @override
  State<AccessibleDictationField> createState() => _AccessibleDictationFieldState();
}

class _AccessibleDictationFieldState extends State<AccessibleDictationField> {
  final TextEditingController _controller = TextEditingController();
  final SttService _sttService = SttService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _sttService.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sttService.stopListening();
    super.dispose();
  }

  void _toggleDictation() async {
    if (_isListening) {
      await _sttService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _sttService.startListening(
        listenMode: ListenMode.dictation,
        onResult: (result) {
          setState(() {
            _controller.text = result;
            widget.onTextChanged(result);
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.semanticLabel,
      child: TextField(
        controller: _controller,
        onChanged: widget.onTextChanged,
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Tap mic to dictate...',
          suffixIcon: IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : null),
            onPressed: _toggleDictation,
            tooltip: _isListening ? 'Stop Dictation' : 'Start Dictation',
          ),
        ),
      ),
    );
  }
}
