import 'package:flutter/material.dart';

import 'screens/tracker_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ReelLogApp());
}

class ReelLogApp extends StatelessWidget {
  const ReelLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entertainment tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const TrackerShell(),
    );
  }
}
