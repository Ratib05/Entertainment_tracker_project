import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/entertainment_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gauoglgismrwxtwsdaci.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI',
  );

  runApp(const ReelLogApp());
}

class ReelLogApp extends StatelessWidget {
  const ReelLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final supabaseClient = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiService: apiService,
            supabaseClient: supabaseClient,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EntertainmentProvider>(
          create: (context) => EntertainmentProvider(apiService),
          update: (context, authProvider, previous) => EntertainmentProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Entertainment tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const LoginScreen(),
      ),
    );
  }
}
