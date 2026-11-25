import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/glowup_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GlowUpProvider(),
      child: const GlowUpApp(),
    ),
  );
}

class GlowUpApp extends StatelessWidget {
  const GlowUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();

    return MaterialApp(
      title: 'GlowUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(
        darkMode: provider.darkMode,
        highContrast: provider.highContrast,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(provider.fontScale / 100.0),
          ),
          child: child!,
        );
      },
      home: provider.currentUser == null
          ? const AuthScreen()
          : const MainShellScreen(),
    );
  }
}
