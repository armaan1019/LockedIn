import "package:flutter/material.dart";
import "../../workout/models/exercise.dart";

class Activity {
  final String title;
  final List<Exercise> exercises;
  final IconData icon;

  Activity({required this.title, required this.exercises, required this.icon});
}
