import 'package:flutter/material.dart';

/// Training Type Chip Widget
/// A modern chip selector for session types (Training, Match, Fitness)
class TrainingTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TrainingTypeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    switch (label) {
      case 'Training':
        chipColor = Colors.blue;
        break;
      case 'Match':
        chipColor = Colors.green;
        break;
      case 'Fitness':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
