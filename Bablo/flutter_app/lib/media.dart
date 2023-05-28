class Video {
  final String title;
  final String videoId;

  Video({required this.title, required this.videoId});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      videoId: json['videoId'] ?? '',
    );
  }
}
