import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/tracker_shell.dart';
import 'theme/app_theme.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
    'Missing SUPABASE_URL/SUPABASE_ANON_KEY. Run with '
    '--dart-define-from-file=dart_define.json (see dart_define.example.json).',
  );

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
  runApp(const ReelLogApp());
}

class ReelLogApp extends StatelessWidget {
  const ReelLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'MediaMine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: hasSession ? const TrackerShell() : const LoginScreen(),
    );
  }
}
