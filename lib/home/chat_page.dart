import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.messages}) : super(key: key);
  final List<Messages> messages;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String serverurl = '';
  void _sendMessage(String message) async {
    setState(() {
      widget.messages.add(Messages(
        role: 'user',
        content: message,
      ));
    });

    final List<Map<String, String>> messagesData = widget.messages
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();
    String? serverurl = await _storage.read(key: 'server_url');
    String url = serverurl! + '/messages';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': messagesData}),
    );

    if (response.statusCode == 200) {
      final completion = jsonDecode(response.body)['completion'].toString();

      setState(() {
        widget.messages.add(Messages(
          role: 'user',
          content: message,
        ));
        widget.messages.add(Messages(
          role: 'assistant',
          content: completion,
        ));
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
    // Scroll to the last message when the page is loaded
    WidgetsBinding.instance?.addPostFrameCallback((_) {
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
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];

                return ListTile(
                  title: Text(
                    message.content,
                    style: TextStyle(
                      color: Color.fromARGB(255, 50, 204, 102),
                    ),
                  ),
                  tileColor: message.role == 'user'
                      ? Colors.black
                      : Color.fromARGB(255, 19, 19, 19),
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
