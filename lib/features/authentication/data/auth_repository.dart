import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opencampus_lms/shared/models/user_profile.dart';
import 'package:opencampus_lms/features/notifications/data/fcm_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    GoogleSignIn.instance,
    ref.read(fcmServiceProvider),
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FcmService _fcmService;

  AuthRepository(this._auth, this._firestore, this._googleSignIn, this._fcmService) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _fcmService.setupFCM(user.uid);
      }
    });
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '632665830727-6brseqmfih7f4vhbdrmk0n2t0b88tu6j.apps.googleusercontent.com',
      );
    } catch (e) {
      debugPrint('GoogleSignIn initialization error: $e');
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _validateStudentRole(credential.user!.uid);
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String fullName, String studentId) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      final uid = credential.user!.uid;
      // Create profile in Firestore
      final profile = UserProfile(
        uid: uid,
        id: uid,
        displayName: fullName,
        email: email,
        studentId: studentId,
        role: UserRole.student, // default to student
        avatar: '',
        joinedAt: DateTime.now().toIso8601String(),
      );
      
      await _firestore.collection('users').doc(uid).set(profile.toJson());
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) return; // User canceled the sign-in

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Check if profile exists
      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile == null) {
        // Create basic profile
        final profile = UserProfile(
          uid: user.uid,
          id: user.uid,
          displayName: user.displayName ?? 'Student',
          email: user.email ?? '',
          role: UserRole.student,
          avatar: user.photoURL ?? '',
          joinedAt: DateTime.now().toIso8601String(),
        );
        await _firestore.collection('users').doc(user.uid).set(profile.toJson());
      } else {
        await _validateStudentRole(user.uid);
      }
    }
  }

  Future<void> _validateStudentRole(String uid) async {
    final profile = await getUserProfile(uid);
    if (profile == null) {
      await signOut();
      throw Exception('User profile not found.');
    }
    if (profile.role != UserRole.student) {
      await signOut();
      throw Exception('Access denied: Student access only.');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final auth = ref.watch(authRepositoryProvider);
  if (auth.currentUser == null) return null;
  return auth.getUserProfile(auth.currentUser!.uid);
});
