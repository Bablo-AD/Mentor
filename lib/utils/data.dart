import 'loader.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:isolate';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:langchain/langchain.dart';

class Data {
  Loader load = Loader();
  static var uuid = const Uuid();
  static final StreamController<Map<String, dynamic>> _journalController =
      StreamController.broadcast();
  static Stream<Map<String, dynamic>> get journalStream =>
      _journalController.stream;
  static StreamSink<Map<String, dynamic>> get journalSink =>
      _journalController.sink;
  static final StreamController<List<Application>> _appController =
      StreamController.broadcast();
  static Stream<List<Application>> get appStream => _appController.stream;
  static StreamSink<List<Application>> get appSink => _appController.sink;
  static Map<String, dynamic> journal = {};
  static String? apikey = "";
  static List<Application> apps = [];
  static List<Application> selected_apps = [];
  static String response = "";
  static String interest = "";
  static List<types.Message> messages_data = [];
  static List<ChatMessage> chatmessages = [];
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
