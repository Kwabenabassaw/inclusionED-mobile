import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/audio_player_controller.dart';

class AudioSettingsSheet extends ConsumerWidget {
  final String currentText;

  const AudioSettingsSheet({super.key, required this.currentText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerControllerProvider);
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audio Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Playback Speed
            Text('Playback Speed', style: Theme.of(context).textTheme.titleMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${speed}x'),
                      selected: state.playbackSpeed == speed,
                      onSelected: (selected) {
                        if (selected) controller.setSpeed(speed);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Voice Selection
            Text('Voice', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: state.selectedVoice,
              isExpanded: true,
              items: ['Joanna', 'Matthew', 'Amy', 'Brian', 'Ruth']
                  .map((voice) => DropdownMenuItem(
                        value: voice,
                        child: Text(voice),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.setVoice(val, currentText);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Download for offline
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download for Offline'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio will be downloaded automatically when played.')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
