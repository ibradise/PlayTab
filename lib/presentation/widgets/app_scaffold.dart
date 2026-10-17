import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'ps_shapes.dart';

/// Full-app backdrop: the warm gradient everything (including glass blur)
/// sits on. Painted once at the MaterialApp level behind the navigator, so
/// no route, app bar area, or transition gap can ever fall through to a
/// default Material color (the "indigo glitch"). Brightness-aware.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gradient = dark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
            colors: [
              Color(0xFF18203A), // faint indigo glow at the top
              kDarkBase,
              Color(0xFF0D101C), // deepest at the bottom
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.35, 1],
            colors: [
              Color(0xFFF2F4F9), // faint PS-blue wash at the top
              kBaseWhite,
              Color(0xFFF8F4EC), // faint warm wash at the bottom
            ],
          );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// Scaffold on the shared warm backdrop. Surfaces stay transparent so the
/// AppBackdrop gradient shows through behind app bars and glass.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: title == null && actions == null
          ? null
          : AppBar(
              title: title == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title!),
                        const SizedBox(width: 10),
                        const PsShapeStrip(size: 11, spacing: 5),
                      ],
                    ),
              actions: actions,
            ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
