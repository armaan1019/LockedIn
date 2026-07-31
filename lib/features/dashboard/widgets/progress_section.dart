import 'package:flutter/material.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'Progress Chart Coming Soon',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}