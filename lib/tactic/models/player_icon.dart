import 'package:flutter/material.dart';

/// Player Icon Model
/// Represents a player icon on the tactic board
class PlayerIcon {
  final String id;
  final int number;
  final Color color;
  Offset position;

  PlayerIcon({
    required this.id,
    required this.number,
    required this.color,
    required this.position,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'number': number,
    'x': position.dx,
    'y': position.dy,
    'color': color.value.toInt(),
  };

  factory PlayerIcon.fromMap(Map<String, dynamic> map) {
    return PlayerIcon(
      id: map['id'] as String,
      number: map['number'] as int,
      color: Color(map['color'] as int),
      position: Offset(
        (map['x'] as num).toDouble(),
        (map['y'] as num).toDouble(),
      ),
    );
  }

  PlayerIcon copyWith({
    String? id,
    int? number,
    Color? color,
    Offset? position,
  }) {
    return PlayerIcon(
      id: id ?? this.id,
      number: number ?? this.number,
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }
}
