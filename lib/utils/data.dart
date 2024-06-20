import 'loader.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:isolate';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class Data {
  Loader load = Loader();
  static var uuid = const Uuid();
  static List<Application> apps = [];
  static List<Application> selected_apps = [];
  static String response = "";
  static String interest = "";
  static List<types.Message> messages_data = [];
  static String serverurl = "";
  static String completion_message = "";
  static List<Video> videoList = [];
  static ReceivePort port = ReceivePort();
  static bool port_state = false;
  static String notification_title = "Mentor-Daily Update";
  static String notification_body = "You have a new message from your mentor";
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
      title: json['title'].toString(),
      videoId: json['videoId'].toString(),
      videoDescription: json['videoDescription'].toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoId': videoId,
      'videoDescription': videoDescription,
    };
  }
}
