import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Frosted-glass card: translucent warm-white with a subtle backdrop blur.
///
/// Use only for major surfaces (a handful per screen) — never wrap long
/// list rows, so a fixed number of blur layers stays on screen.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = 16,
    this.opacity = 0.72,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  /// Glass strength: 1.0 = solid, lower = more transparent.
  final double opacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = GlassColors.modulate(GlassColors.fill(brightness), opacity);
    final fillAlt =
        GlassColors.modulate(GlassColors.fillAlt(brightness), opacity);
    final border = borderColor ?? GlassColors.border(brightness);
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fill, fillAlt],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: GlassColors.shadow(brightness),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Flat translucent tile used *inside* a glass card. No blur — it sits over
/// opaque-ish glass, so blur would be wasted work.
class GlassTile extends StatelessWidget {
  const GlassTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: GlassColors.tileFill(brightness),
        border: Border.all(
          color: brightness == Brightness.dark
              ? const Color(0x1FFFFFFF)
              : kHairline.withValues(alpha: 0.8),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
