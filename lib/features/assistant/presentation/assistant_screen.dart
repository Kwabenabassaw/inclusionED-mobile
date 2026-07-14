import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/providers/voice_providers.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hello! I am your InclusiveEd Learning Assistant. How can I help you today?',
    },
  ];
  
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  StreamSubscription<String>? _transcriptSub;

  @override
  void dispose() {
    _transcriptSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    final engine = ref.read(speechEngineProvider);
    
    if (_isListening) {
      await engine.stopListening();
      setState(() {
        _isListening = false;
        if (!engine.isRealTimeStreaming) {
          _isProcessing = true; // Wait for batch whisper processing
        }
      });
    } else {
      await engine.initialize();
      setState(() => _isListening = true);
      
      _transcriptSub?.cancel();
      _transcriptSub = engine.transcriptStream.listen((transcript) async {
        setState(() {
          _controller.text = transcript;
        });
        
        // Process intent using the unified sendMessage flow
        await _sendMessage(overrideText: transcript);
      });
      
      await engine.startListening();
    }
  }

  Future<void> _sendMessage({String? overrideText}) async {
    final text = overrideText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
      });
      if (overrideText == null) {
        _controller.clear();
      }
      _isProcessing = true;
    });

    final parser = ref.read(fuzzyCommandInterpreterProvider);
    final actionData = parser.parse(text);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (actionData != null) {
        // We found a valid intent!
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Executing command: ${actionData['action']}',
          });
        });
        await ref.read(voiceActionHandlerProvider).handleAction(actionData, context, '');
      } else {
        // Invalid intent
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Sorry, I didn\'t catch that. You can say things like "Open Courses", "Go back", or "Read screen".',
          });
        });
        await ref.read(voiceActionHandlerProvider).handleAction(null, context, '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
                    padding: const EdgeInsets.all(AppDimensions.stackMd),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        color: isUser ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: AppDimensions.stackSm),
                if (_isProcessing)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                    onPressed: _toggleVoice,
                    tooltip: 'Voice Commands',
                  ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
