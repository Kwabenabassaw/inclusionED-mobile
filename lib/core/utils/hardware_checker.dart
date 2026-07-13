import 'package:system_info_plus/system_info_plus.dart';

class HardwareChecker {
  static Future<bool> checkRamForLLM() async {
    try {
      final int? deviceMemoryMB = await SystemInfoPlus.physicalMemory;
      if (deviceMemoryMB != null) {
        return deviceMemoryMB >= 2000; // 2GB minimum
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
