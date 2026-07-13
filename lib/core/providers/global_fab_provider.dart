
import 'package:flutter_riverpod/legacy.dart';

/// Provider to allow child screens to hide the global voice command FAB in MainScaffold.
final hideGlobalFabProvider = StateProvider<bool>((ref) => false);
