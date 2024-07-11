// ignore_for_file: avoid_print, unused_element
import 'dart:convert';
import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../data.dart';

// /// The most basic building block of LangChain is calling an LLM on some input.
// Future<void> _example1() async {
//   final openAiApiKey = Data.apikey;
//   final llm = OpenAI(
//     apiKey: openAiApiKey,
//     defaultOptions: const OpenAIOptions(temperature: 0.9),
//   );
//   final LLMResult res = await llm.invoke(
//     PromptValue.string('Tell me a joke'),
//   );
//   print(res);
// }

// /// The most frequent use case is to create a chat-bot.
// /// This is the most basic one.
// Future<void> _example2() async {
//   final openaiApiKey = Data.apikey;
//   final chat = ChatOpenAI(
//     apiKey: openaiApiKey,
//     defaultOptions: const ChatOpenAIOptions(
//       temperature: 0,
//     ),
//   );

//   while (true) {
//     stdout.write('> ');
//     final usrMsg = ChatMessage.humanText(stdin.readLineSync() ?? '');
//     final aiMsg = await chat([usrMsg]);
//     print(aiMsg.content);
//   }
//}

// This is a reference class to show the input and output structure
class Response {
  static Future<String> getresponse(String json, String messagehistory) async {
    final openAiApiKey = Data.apikey;
    final llm = OpenAI(
      apiKey: openAiApiKey,
      defaultOptions: const OpenAIOptions(temperature: 0.9),
    );
    //print(openAiApiKey);
    final LLMResult res = await llm.invoke(
      PromptValue.string(json),
    );
    Map<String, dynamic> videos = {
      "videoId": "video1",
      "title": "First Video",
      "videoDescription": "https://example.com/video1"
    };

    Map<String, dynamic> output = {
      "response": [res.generations[0].output],
      "videos": videos,
      "notification": {"title": "This is title", "message": "Message"},
      "message_history":
          "$messagehistory,{'role':'assistant','content':'${res.generations[0].output}'",
    };
    print(output);
    return jsonEncode(output);
  }
}
