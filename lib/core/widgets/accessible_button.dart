import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Widget child;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
