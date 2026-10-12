import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/hub_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/community_provider.dart';
import 'features/navigation/presentation/main_nav_screen.dart';
import 'features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  final apiClient = ApiClient(storage: storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient: apiClient, storage: storage)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => HubProvider(apiClient: apiClient, storage: storage),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => LeaderboardProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityProvider(apiClient: apiClient),
        ),
      ],
      child: const EloFitApp(),
    ),
  );
}

class EloFitApp extends StatelessWidget {
  const EloFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EloFit',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC5A869),
          primary: const Color(0xFFC5A869),
          surface: const Color(0xFFF8F8FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainNavScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
