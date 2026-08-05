import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onPastWorkouts;
  final void Function(Workout)? onEdit;
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onPastWorkouts,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final visibleExercises = workout.exercises.take(3).toList();
    final remaining = workout.exercises.length - visibleExercises.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 26,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${workout.exercises.length} exercises',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton(
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      child: const Text("Edit Workout"),
                      onTap: () {
                        Future.delayed(
                          Duration.zero,
                          () => onEdit!(workout),
                        );
                      },
                    ),

                  if (onDelete != null)
                    PopupMenuItem(
                      onTap: onDelete,
                      child: const Text("Delete Workout"),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Exercise list
          ...visibleExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      exercise.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Text(
                    '${exercise.sets} × ${exercise.reps}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+ $remaining more exercises',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Workout"),
                ),
              ),

              const SizedBox(width: 12),

              IconButton.filledTonal(
                onPressed: onPastWorkouts,
                icon: const Icon(Icons.history),
                tooltip: "Past Workouts",
              ),
            ],
          ),
        ],
      ),
    );
  }
}