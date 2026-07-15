import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

class AiChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Hardcoded for now per user request. 
  // In production, this should be moved to flutter_dotenv or Firebase Remote Config.
  // API key removed - use dotenv.env["GEMINI_API_KEY"]
  
  late final GenerativeModel _model;

  AiChatService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> _buildCourseContext(String courseId) async {
    try {
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      if (!courseDoc.exists) return "Course not found.";
      
      final courseData = courseDoc.data()!;
      String context = "Course Name: ${courseData['title'] ?? courseData['name'] ?? 'Unknown'}\n";
      context += "Description: ${courseData['description'] ?? 'No description'}\n\n";

      // Fetch modules
      final modulesQuery = await _firestore.collection('modules')
          .where('courseId', isEqualTo: courseId)
          .orderBy('orderIndex')
          .get();
          
      if (modulesQuery.docs.isNotEmpty) {
        context += "Modules in this course:\n";
        for (var modDoc in modulesQuery.docs) {
          final modData = modDoc.data();
          context += "- ${modData['title']} (Description: ${modData['description']})\n";
          
          // Fetch contents for this module
          final contentsQuery = await _firestore.collection('contents')
              .where('moduleId', isEqualTo: modDoc.id)
              .get();
              
          for (var contentDoc in contentsQuery.docs) {
            context += "  * Content: ${contentDoc.data()['title']} (${contentDoc.data()['type']})\n";
          }
        }
      }
      return context;
    } catch (e) {
      print("Error building course context: $e");
      return "Failed to retrieve specific course materials.";
    }
  }

  Future<String> sendMessage(String studentId, String? courseId, String messageText) async {
    try {
      final normalizedCourseId = courseId ?? 'general';
      
      // 1. Fetch Chat Session History from Firestore
      final sessionsQuery = await _firestore.collection('chat_sessions')
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: normalizedCourseId)
          .limit(1)
          .get();

      String sessionId;
      if (sessionsQuery.docs.isEmpty) {
        final newSessionRef = await _firestore.collection('chat_sessions').add({
          'studentId': studentId,
          'courseId': normalizedCourseId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        sessionId = newSessionRef.id;
      } else {
        sessionId = sessionsQuery.docs.first.id;
      }

      final messagesQuery = await _firestore.collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .limitToLast(20)
          .get();

      // Convert Firestore history to Gemini Content history
      final List<Content> history = [];
      for (var doc in messagesQuery.docs) {
        final data = doc.data();
        final role = data['role'] == 'user' ? 'user' : 'model';
        history.add(Content(role, [TextPart(data['content'] ?? '')]));
      }

      // 2. Build Context if there's a course
      String systemInstruction = "You are an AI Learning Companion for InclusiveEd. Act as a personal, encouraging tutor. Use simple language and adapt to the student's needs. Do not give direct answers for assignments; instead, guide the student.";
      
      if (courseId != null) {
        final courseContext = await _buildCourseContext(courseId);
        systemInstruction += "\n\nCurrent Course Context:\n$courseContext";
      }

      // We inject system instruction into a GenerativeModel specifically for this chat
      final chatModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction),
      );

      // Initialize Gemini Chat Session with history
      final chat = chatModel.startChat(history: history);

      // 3. Save User Message to Firestore
      await _firestore.collection('chat_sessions').doc(sessionId).collection('messages').add({
        'role': 'user',
        'content': messageText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('chat_sessions').doc(sessionId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Send Message to Gemini
      final response = await chat.sendMessage(Content.text(messageText));
      final replyText = response.text ?? "Sorry, I couldn't process that.";

      // 5. Save Model Response to Firestore
      await _firestore.collection('chat_sessions').doc(sessionId).collection('messages').add({
        'role': 'model',
        'content': replyText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return replyText;
    } catch (e) {
      print('AI Chat Error: $e');
      return "Sorry, I am having trouble thinking right now. Please try again later.";
    }
  }
}
