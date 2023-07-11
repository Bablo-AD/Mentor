import 'package:flutter/material.dart';
import '../core/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/loader.dart';

class ChatPage extends StatefulWidget {
  final String response;

  const ChatPage({Key? key, required this.response}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Messages> messages = Data.messages_data;
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final Loader _loader = Loader();
  String serverurl = '';
  void _sendMessage(String message) async {
    setState(() {
      messages.add(Messages(
        role: 'user',
        content: message,
      ));
    });

    final List<Map<String, String>> messagesData = messages
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();
    String? serverurl = await _storage.read(key: 'server_url');
    String url = '${serverurl!}/mentor/messages';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': messagesData}),
    );

    if (response.statusCode == 200) {
      final completion = jsonDecode(response.body)['completion'].toString();

      setState(() {
        messages.add(Messages(
          role: 'user',
          content: message,
        ));
        messages.add(Messages(
          role: 'assistant',
          content: completion,
        ));
        _loader.saveMessages(messages);
      });
    } else {
      // Handle error case
      print('Error: ${response.statusCode}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('An error occurred'),
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

    // Clear the text input field
    textEditingController.clear();
  }

  @override
  void initState() {
    super.initState();
    _loader.loadMessages();
    setState() {
      Data.messages_data
          .add(Messages(role: "assistant", content: widget.response));
      _loader.saveMessages(Data.messages_data);
      messages = Data.messages_data;
    }

    // Scroll to the last message when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor/Chat',
            style: TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return ListTile(
                  title: Text(
                    message.content,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 50, 204, 102),
                    ),
                  ),
                  tileColor: message.role == 'user'
                      ? Colors.black
                      : const Color.fromARGB(255, 19, 19, 19),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 50, 204, 102),
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 19, 19, 19),
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 50, 204, 102),
                      ),
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 50, 204, 102),
                  ),
                  onPressed: () {
                    final message = textEditingController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
