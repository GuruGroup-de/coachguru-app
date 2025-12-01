/// Player Position Model
/// Represents a player's position on the tactic board
class PlayerPosition {
  final String id;
  double x;
  double y;

  PlayerPosition({required this.id, required this.x, required this.y});

  Map<String, dynamic> toMap() => {'id': id, 'x': x, 'y': y};

  factory PlayerPosition.fromMap(Map<String, dynamic> map) {
    return PlayerPosition(
      id: map['id'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }

  PlayerPosition copyWith({String? id, double? x, double? y}) {
    return PlayerPosition(id: id ?? this.id, x: x ?? this.x, y: y ?? this.y);
  }
}
