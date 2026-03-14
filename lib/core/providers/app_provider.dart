import 'package:provider/provider.dart';
import '../../features/workout/repositories/workout_repository.dart';
import '../services/session_manager.dart';
import '../../features/workout/repositories/workout_session_repository.dart';
import 'package:provider/single_child_widget.dart';

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
];
