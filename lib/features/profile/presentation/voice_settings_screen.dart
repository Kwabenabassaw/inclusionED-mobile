import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceSettingsScreen extends ConsumerStatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  ConsumerState<VoiceSettingsScreen> createState() =>
      _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends ConsumerState<VoiceSettingsScreen> {
  final FlutterTts _localTtsForQuery = FlutterTts();
  List<Map<String, String>> _nativeVoices = [];
  bool _isLoadingNativeVoices = true;
  final String _previewText =
      "Welcome to Inclusive Ed. This is a preview of your synthesized reading voice.";

  final List<String> _pollyVoices = [
    'Joanna',
    'Salli',
    'Matthew',
    'Justin',
    'Kendra',
    'Joey',
    'Ivy',
    'Kevin',
  ];

  @override
  void initState() {
    super.initState();
    _loadNativeVoices();
  }

  Future<void> _loadNativeVoices() async {
    try {
      final dynamic voices = await _localTtsForQuery.getVoices;
      if (voices is List) {
        final parsed = voices
            .map((e) {
              final map = Map<dynamic, dynamic>.from(e as Map);
              return {
                'name': map['name']?.toString() ?? '',
                'locale': map['locale']?.toString() ?? '',
              };
            })
            .where(
              (v) =>
                  (v['locale']?.toLowerCase().startsWith('en') ?? false) &&
                  (v['name']?.isNotEmpty ?? false),
            )
            .toList();

        if (mounted) {
          setState(() {
            _nativeVoices = parsed;
            _isLoadingNativeVoices = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingNativeVoices = false);
        }
      }
    } catch (e) {
      debugPrint('Error fetching native voices: $e');
      if (mounted) {
        setState(() => _isLoadingNativeVoices = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);
    final playback = ref.watch(playbackControllerProvider);

    final isPolly = settings.ttsEngine == 'polly';
    final currentSpeed = isPolly ? settings.pollySpeed : settings.nativeSpeed;
    final currentPitch = isPolly ? settings.pollyPitch : settings.nativePitch;
    final currentVolume = isPolly
        ? settings.pollyVolume
        : settings.nativeVolume;
    final currentVoice = isPolly ? settings.pollyVoice : settings.nativeVoice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voice Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreviewCard(theme, playback, currentVoice),
            SizedBox(height: 24),
            _buildEngineSelector(theme, settings.ttsEngine, notifier),
            SizedBox(height: 24),
            _buildVoiceDropdown(theme, isPolly, currentVoice, notifier),
            SizedBox(height: 24),
            _buildSliderCard(
              theme: theme,
              title: 'Reading Speed',
              value: currentSpeed,
              min: 0.5,
              max: 3.0,
              icon: Icons.speed,
              label: '${currentSpeed.toStringAsFixed(1)}x',
              onChanged: (val) {
                if (isPolly) {
                  notifier.setPollySpeed(val);
                } else {
                  notifier.setNativeSpeed(val);
                }
              },
              onChangeEnd: (val) {
                ref
                    .read(playbackControllerProvider.notifier)
                    .changeSettingsAndResume();
              },
            ),
            SizedBox(height: 16),
            _buildSliderCard(
              theme: theme,
              title: 'Voice Pitch',
              value: currentPitch,
              min: 0.5,
              max: 2.0,
              icon: Icons.music_note,
              label: currentPitch.toStringAsFixed(1),
              onChanged: (val) {
                if (isPolly) {
                  notifier.setPollyPitch(val);
                } else {
                  notifier.setNativePitch(val);
                }
              },
              onChangeEnd: (val) {
                ref
                    .read(playbackControllerProvider.notifier)
                    .changeSettingsAndResume();
              },
            ),
            SizedBox(height: 16),
            _buildSliderCard(
              theme: theme,
              title: 'Volume Level',
              value: currentVolume,
              min: 0.0,
              max: 1.0,
              icon: Icons.volume_up,
              label: '${(currentVolume * 100).toInt()}%',
              onChanged: (val) {
                if (isPolly) {
                  notifier.setPollyVolume(val);
                } else {
                  notifier.setNativeVolume(val);
                }
              },
              onChangeEnd: (val) {
                ref
                    .read(playbackControllerProvider.notifier)
                    .changeSettingsAndResume();
              },
            ),
            SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  'Continuous Listening (Wake Word)',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Say "Hey Inclusion Ed" or "Porcupine" to activate voice commands.'),
                value: settings.continuousListening,
                onChanged: (val) {
                  notifier.toggleContinuousListening();
                },
                secondary: Icon(Icons.mic, color: theme.colorScheme.primary),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(
    ThemeData theme,
    PlaybackData playback,
    String voice,
  ) {
    final isPlaying =
        playback.state == PlaybackState.speaking &&
        playback.currentTextToSpeak.contains("Inclusive Ed");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              SizedBox(width: 8),
              Text(
                'Voice Test Preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _previewText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final controller = ref.read(playbackControllerProvider.notifier);
              if (isPlaying) {
                controller.pause();
              } else {
                controller.playOrResume(_previewText);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(isPlaying ? 'Pause Preview' : 'Test Speech'),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSelector(
    ThemeData theme,
    String activeEngine,
    AccessibilityNotifier notifier,
  ) {
    final isPolly = activeEngine == 'polly';
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEngineOption(
              label: 'AWS Polly (Cloud)',
              isSelected: isPolly,
              theme: theme,
              onTap: () {
                notifier.setTtsEngine('polly');
                ref
                    .read(playbackControllerProvider.notifier)
                    .stopForNavigation();
              },
            ),
          ),
          Expanded(
            child: _buildEngineOption(
              label: 'System (Offline)',
              isSelected: !isPolly,
              theme: theme,
              onTap: () {
                notifier.setTtsEngine('native');
                ref
                    .read(playbackControllerProvider.notifier)
                    .stopForNavigation();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineOption({
    required String label,
    required bool isSelected,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceDropdown(
    ThemeData theme,
    bool isPolly,
    String currentVoice,
    AccessibilityNotifier notifier,
  ) {
    if (!isPolly && _isLoadingNativeVoices) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<DropdownMenuItem<String>> items = [];

    if (isPolly) {
      for (final voice in _pollyVoices) {
        items.add(
          DropdownMenuItem(
            value: voice,
            child: Text(
              '$voice (Polly)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
    } else {
      items.add(
        const DropdownMenuItem(
          value: 'default',
          child: Text(
            'Default System Voice',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
      for (final voice in _nativeVoices) {
        final name = voice['name'] ?? '';
        items.add(
          DropdownMenuItem(
            value: name,
            child: Text(
              name.length > 25 ? '${name.substring(0, 25)}...' : name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
    }

    // Guard against currentVoice not being in items list
    final hasMatchingItem = items.any((item) => item.value == currentVoice);
    final selectedValue = hasMatchingItem
        ? currentVoice
        : (isPolly ? 'Joanna' : 'default');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            items: items,
            onChanged: (val) {
              if (val != null) {
                if (isPolly) {
                  notifier.setPollyVoice(val);
                } else {
                  notifier.setNativeVoice(val);
                }
                ref.read(playbackControllerProvider.notifier).setVoice(val);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required ThemeData theme,
    required String title,
    required double value,
    required double min,
    required double max,
    required IconData icon,
    required String label,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ],
        ),
      ),
    );
  }
}
