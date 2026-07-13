import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius = AppDimensions.radiusLg,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: MouseRegion(
          cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Semantics(
            button: widget.onTap != null,
            child: GestureDetector(
              onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: widget.onTap != null ? (_) {
                setState(() => _isPressed = false);
                widget.onTap!();
              } : null,
              onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? theme.colorScheme.surface.withValues(alpha: _isHovered ? 0.7 : 0.6)
                            : theme.colorScheme.surface.withValues(alpha: _isHovered ? 0.9 : 0.8),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.onSurface.withValues(alpha: _isHovered ? 0.15 : 0.08)
                              : theme.colorScheme.onSurface.withValues(alpha: _isHovered ? 0.1 : 0.05),
                          width: 1.5,
                        ),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
