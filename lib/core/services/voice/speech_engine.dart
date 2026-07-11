import 'dart:async';

abstract class SpeechEngine {
  /// Stream of recognized words
  Stream<String> get transcriptStream;
  
  /// Stream of real-time interim results (optional, primarily for NativeSTT)
  Stream<String> get interimTranscriptStream;
  
  /// Indicates if this engine streams results in real-time (true) or batches them after listening stops (false).
  bool get isRealTimeStreaming; 
  
  /// Initialize the engine
  Future<void> initialize();
  
  /// Start listening/recording
  Future<void> startListening();
  
  /// Stop listening/recording and process if needed
  Future<void> stopListening();
  
  /// Dispose any resources
  void dispose();
}
