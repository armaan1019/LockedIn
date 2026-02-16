import 'package:flutter/material.dart';

class ExerciseInput extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController setsController;
  final TextEditingController repsController;

  ExerciseInput({
    super.key,
    String? name,
    int? sets,
    int? reps,
  })  : nameController = TextEditingController(text: name ?? ''),
        setsController = TextEditingController(text: sets?.toString() ?? ''),
        repsController = TextEditingController(text: reps?.toString() ?? '');

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Num' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Num' : null,
            ),
          ),
        ],
      ),
    );
  }
}