// ignore_for_file: avoid_print, unused_element
import 'dart:convert';
import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../data.dart';
// To Do:
// 1. AI response history
// OUTPUT PARSING
// 2. RAG Implement(userdata)
// 3. Content Recommendation
// 4. Progress points
// 5. RAG (external data)

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
  static Future<String> getresponse(String message) async {
    final openAiApiKey = Data.apikey;
    final llm = ChatOpenAI(
      apiKey: openAiApiKey,
    );
    //print(openAiApiKey);
    const template = '''
I want you to act as a productivity assistant.
this is user data {message}
''';
    final promptTemplate = PromptTemplate.fromTemplate(template);
    final prompt = promptTemplate.format({'message': message});
    Data.chatmessages.insert(0, ChatMessage.system(prompt));
    final res = await llm.invoke(
      PromptValue.chat(Data.chatmessages),
    );
    print(res);
    Data.chatmessages
        .insert(0, ChatMessage.ai(res.generations[0].output.content));

    return res.generations[0].output.content;
  }
}
