import 'package:flutter/material.dart';
import '../core/data.dart';
import 'make_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/loader.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String response;

  const ChatPage({Key? key, required this.response}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Messages> messages = Data.messages_data;
  List<Messages> new_messages = [];
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  final Loader _loader = Loader();
  String serverurl = '';
  bool loading = false;
  void _sendMessage(String message) async {
    setState(() {
      loading = true;
      new_messages.clear();
      new_messages.add(Messages(
        role: 'user',
        content: message,
      ));
    });
    DataProcessor sender = DataProcessor(context);
    final List<Map<String, String>> messagesData = new_messages
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();
    http.Response response =
        await sender.meet_with_server(messagesData.toString());
    if (response.statusCode == 200) {
      final completion = jsonDecode(response.body)['response'].toString();

      setState(() {
        loading = false;
        new_messages.add(Messages(
          role: 'assistant',
          content: completion,
        ));
        messages = [...messages, ...new_messages];
      });
    } else {
      // Handle error case
      print('Error: ${response.statusCode}');
      setState(() {
        loading = false;
      });
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

    // Clear the text input field
    textEditingController.clear();
  }

  @override
  void initState() {
    super.initState();
    _loader.loadMessages().then((message) {
      setState(() {
        Data.messages_data = message;
        messages = message;
      });
    });
    // Scroll to the last message when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Mentor/Chat',
      )),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                    alignment: message.role == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Card(
                      margin: const EdgeInsets.all(15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text("${message.role}\n${message.content}"),
                      ),
                    ));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      hintStyle: TextStyle(),
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                if (loading == true)
                  Container(
                    width: 50.0, // Adjust these values to suit your needs
                    height: 50.0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                            10.0), // Adjust this value to suit your needs
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.send,
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
