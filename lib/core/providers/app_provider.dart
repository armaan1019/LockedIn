import 'package:provider/provider.dart';
import '../../features/workout/repositories/workout_repository.dart';
import '../services/session_manager.dart';
import '../../features/workout/repositories/workout_session_repository.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/diet/repositories/diet_repository.dart';
import '../../features/dashboard/repositories/recent_activity_repository.dart';
import '../../features/dashboard/repositories/stats_repository.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => SessionManager()),

  ProxyProvider<SessionManager, WorkoutRepository?>(
    update: (context, sessionManager, previous) {
      final userId = sessionManager.currentUserId;

      if (userId == null) return null;

      return WorkoutRepository(userId: userId);
    },
  ),
  ProxyProvider<SessionManager, WorkoutSessionRepository?>(
    update: (context, sessionManager, previous) {
      final userId = sessionManager.currentUserId;

      if (userId == null) return null;

      return WorkoutSessionRepository(userId: userId);
    },
  ),
  ProxyProvider<SessionManager, DietRepository?>(
    update: (context, sessionManager, previous) {
      final userId = sessionManager.currentUserId;

      if (userId == null) return null;

      return DietRepository(userId: userId);
    },
  ),
  ProxyProvider<SessionManager, DashboardRepository?>(
    update: (context, sessionManager, previous) {
      final userId = sessionManager.currentUserId;

      if (userId == null) return null;

      return DashboardRepository(userId: userId);
    },
  ),
  ProxyProvider<SessionManager, StatsRepository?>(
    update: (context, sessionManager, previous) {
      final userId = sessionManager.currentUserId;

      if (userId == null) return null;

      return StatsRepository(userId: userId);
    },
  ),
];
