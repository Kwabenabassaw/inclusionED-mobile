import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class ScreenReaderAlert {
  static void announce(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }
}
