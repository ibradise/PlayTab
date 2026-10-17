import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/di.dart';
import 'core/theme_controller.dart';
import 'domain/repositories/settings_repository.dart';
import 'presentation/pages/stations_page.dart';
import 'presentation/widgets/app_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  final themeController = ThemeController();
  sl.registerSingleton<ThemeController>(themeController);
  // Load the saved theme before the first frame — no flash on startup.
  await themeController.init(sl<SettingsRepository>());
  runApp(PlayTabApp(themeController: themeController));
}

class PlayTabApp extends StatelessWidget {
  const PlayTabApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final dark = themeController.isDark;
        return MaterialApp(
          title: 'PS Zone Game Tracker',
          debugShowCheckedModeBanner: false,
          color: dark ? kDarkBase : kBaseWhite,
          theme: buildPlayTabTheme(Brightness.light),
          darkTheme: buildPlayTabTheme(Brightness.dark),
          themeMode: themeController.mode,
          builder: (_, child) => AppBackdrop(child: child ?? const SizedBox()),
          home: const StationsPage(),
        );
      },
    );
  }
}
