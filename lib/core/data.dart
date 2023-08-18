import 'package:firebase_auth/firebase_auth.dart';

class Data {
  static String? userId = FirebaseAuth.instance.currentUser?.uid;
  static String response = "";
  static String interest = "";
  static List<Messages> messages_data = [];
  static String completion_message = "";
  static List<Video> videoList = [];
}

class Video {
  final String title;
  final String videoId;
  final String videoDescription;

  Video(
      {required this.title,
      required this.videoId,
      required this.videoDescription});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'].toString() ?? '',
      videoId: json['videoId'].toString() ?? '',
      videoDescription: json['videoDescription'].toString() ?? '',
    );
  }
}

class Messages {
  final String role;
  final String content;

  Messages({required this.role, required this.content});
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
