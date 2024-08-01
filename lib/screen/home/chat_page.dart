import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:langchain/langchain.dart';
import 'dart:convert';

import '../../utils/data.dart';
import '../../utils/make_request.dart';
import '../../utils/loader.dart';
import 'dart:math';

//import 'package:cloud_firestore/cloud_firestore.dart';
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _user = const types.User(id: 'user');
  final _mentor = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac', firstName: "Mentor");
  DataProcessor sender = DataProcessor();
  List<types.User> typing_users = [];
  final Loader _loader = Loader();
  @override
  void initState() {
    super.initState();
    loader();
  }

  void loader() async {
    List<types.Message> val = await _loader.loadMessages();

    setState(() {
      Data.messages_data = val;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Mentor/Chat"),
          centerTitle: true,
        ),
        body: Chat(
          messages: Data.messages_data,
          onSendPressed: _handleSendPressed,
          user: _user,
          theme: const DarkChatTheme(),
          typingIndicatorOptions:
              TypingIndicatorOptions(typingUsers: typing_users),
        ),
      );

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Data.uuid.v1(),
      text: message.text,
    );
    setState(() {
      Data.chatmessages.insert(0, ChatMessage.humanText(message.text));
      Data.messages_data.insert(0, textMessage);
      typing_users = [_mentor];
    });

    String? response = await sender.processing(message.text);
    final mentorMessage = types.TextMessage(
      author: const types.User(id: 'mentor'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Data.uuid.v1(),
      text: response.toString(),
    );
    Data.messages_data.insert(0, mentorMessage);
    if (mounted) {
      setState(() {
        Data.messages_data;
        typing_users = [];
      });
    }
    ;
  }
}
