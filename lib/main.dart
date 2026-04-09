import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/task_management_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/habit_tracking_screen.dart';
import 'screens/calendar_sync_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScheduleManagerApp());
}

class ScheduleManagerApp extends StatelessWidget {
  const ScheduleManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'OFFTRACK',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/tasks': (context) => const TaskManagementScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/habits': (context) => const HabitTrackingScreen(),
          '/calendar': (context) => const CalendarSyncScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/help': (context) => const HelpSupportScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
