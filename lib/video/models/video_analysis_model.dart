/// Video Moment Model
/// Represents a key moment in a video analysis
class VideoMoment {
  final Duration timestamp;
  final String type; // Goal, Shot, Assist, Foul, Custom
  final String? player;
  final String comment;
  final String thumbnailPath;

  VideoMoment({
    required this.timestamp,
    required this.type,
    this.player,
    required this.comment,
    required this.thumbnailPath,
  });

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp.inMilliseconds,
    'type': type,
    'player': player,
    'comment': comment,
    'thumbnailPath': thumbnailPath,
  };

  factory VideoMoment.fromMap(Map<String, dynamic> map) => VideoMoment(
    timestamp: Duration(milliseconds: map['timestamp'] as int),
    type: map['type'] as String,
    player: map['player'] as String?,
    comment: map['comment'] as String,
    thumbnailPath: map['thumbnailPath'] as String,
  );
}

/// Video Analysis Model
/// Represents a complete video analysis with moments
class VideoAnalysisModel {
  final String videoPath;
  final List<VideoMoment> moments;

  VideoAnalysisModel({required this.videoPath, required this.moments});

  Map<String, dynamic> toMap() => {
    'videoPath': videoPath,
    'moments': moments.map((m) => m.toMap()).toList(),
  };

  factory VideoAnalysisModel.fromMap(Map<String, dynamic> map) =>
      VideoAnalysisModel(
        videoPath: map['videoPath'] as String,
        moments: (map['moments'] as List)
            .map((m) => VideoMoment.fromMap(m as Map<String, dynamic>))
            .toList(),
      );
}
