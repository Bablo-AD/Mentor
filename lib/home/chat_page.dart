import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../core/data.dart';
import 'make_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/loader.dart';
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
  Loader _loader = Loader();
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
          title: Text("Mentor/Chat"),
          centerTitle: true,
        ),
        body: Chat(
          messages: Data.messages_data,
          onSendPressed: _handleSendPressed,
          user: _user,
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
      Data.messages_data.insert(0, textMessage);
      typing_users = [_mentor];
    });

    http.Response response = await sender.meet_with_server(message.text);
    if (response.statusCode == 200) {
      sender.post_process_data(response.body);
      if (mounted) {
        setState(() {
          Data.messages_data;
          typing_users = [];
        });
      }
    } else {
      // Handle error case
      print('Error: ${response.statusCode}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('An error occurred try again later'),
            content: Text(response.statusCode.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
