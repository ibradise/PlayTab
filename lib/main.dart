import 'package:flutter/material.dart';

import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const PlayTabApp());
}

class PlayTabApp extends StatelessWidget {
  const PlayTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PS Zone Game Tracker',
      home: const Scaffold(
        body: Center(child: Text('PS Zone Game Tracker')),
      ),
    );
  }
}
