import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _courseUpdates = true;
  bool _newMaterials = true;
  bool _quizzes = true;
  bool _announcements = true;
  bool _calendar = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final prefs = data['notificationPreferences'] as Map<String, dynamic>? ?? {};
          setState(() {
            _courseUpdates = prefs['courseUpdates'] ?? true;
            _newMaterials = prefs['newMaterials'] ?? true;
            _quizzes = prefs['quizzes'] ?? true;
            _announcements = prefs['announcements'] ?? true;
            _calendar = prefs['calendar'] ?? true;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Error loading preferences: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'notificationPreferences': {
            'courseUpdates': _courseUpdates,
            'newMaterials': _newMaterials,
            'quizzes': _quizzes,
            'announcements': _announcements,
            'calendar': _calendar,
          }
        }, SetOptions(merge: true));
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save preferences')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Course Updates & New Weeks'),
            subtitle: const Text('Receive notifications when courses or modules are published.'),
            value: _courseUpdates,
            onChanged: (val) {
              setState(() => _courseUpdates = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('New Lessons & Materials'),
            subtitle: const Text('Receive notifications when new reading materials are added.'),
            value: _newMaterials,
            onChanged: (val) {
              setState(() => _newMaterials = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Quizzes & Grades'),
            subtitle: const Text('Receive notifications for new quizzes or assignments.'),
            value: _quizzes,
            onChanged: (val) {
              setState(() => _quizzes = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Announcements'),
            subtitle: const Text('Receive instructor announcements.'),
            value: _announcements,
            onChanged: (val) {
              setState(() => _announcements = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Calendar Events'),
            subtitle: const Text('Receive notifications for scheduled events.'),
            value: _calendar,
            onChanged: (val) {
              setState(() => _calendar = val);
              _savePreferences();
            },
          ),
        ],
      ),
    );
  }
}
