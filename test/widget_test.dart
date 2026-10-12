import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:elofit/core/network/api_client.dart';
import 'package:elofit/core/storage/storage_service.dart';
import 'package:elofit/providers/auth_provider.dart';
import 'package:elofit/providers/hub_provider.dart';
import 'package:elofit/providers/workout_provider.dart';
import 'package:elofit/providers/leaderboard_provider.dart';
import 'package:elofit/providers/community_provider.dart';
import 'package:elofit/main.dart';

void main() {
  testWidgets('EloFitApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final apiClient = ApiClient(storage: storage);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(apiClient: apiClient, storage: storage)),
          ChangeNotifierProvider(create: (_) => HubProvider(apiClient: apiClient, storage: storage)),
          ChangeNotifierProvider(create: (_) => WorkoutProvider(apiClient: apiClient)),
          ChangeNotifierProvider(create: (_) => LeaderboardProvider(apiClient: apiClient)),
          ChangeNotifierProvider(create: (_) => CommunityProvider(apiClient: apiClient)),
        ],
        child: const EloFitApp(),
      ),
    );

    expect(find.text('ELOFIT'), findsOneWidget);
  });
}
