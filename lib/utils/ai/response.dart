// ignore_for_file: avoid_print, unused_element
import 'dart:convert';
import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../data.dart';

/// The most basic building block of LangChain is calling an LLM on some input.
Future<void> _example1() async {
  final openAiApiKey = Data.apikey;
  final llm = OpenAI(
    apiKey: openAiApiKey,
    defaultOptions: const OpenAIOptions(temperature: 0.9),
  );
  final LLMResult res = await llm.invoke(
    PromptValue.string('Tell me a joke'),
  );
  print(res);
}

/// The most frequent use case is to create a chat-bot.
/// This is the most basic one.
Future<void> _example2() async {
  final openaiApiKey = Data.apikey;
  final chat = ChatOpenAI(
    apiKey: openaiApiKey,
    defaultOptions: const ChatOpenAIOptions(
      temperature: 0,
    ),
  );

  while (true) {
    stdout.write('> ');
    final usrMsg = ChatMessage.humanText(stdin.readLineSync() ?? '');
    final aiMsg = await chat([usrMsg]);
    print(aiMsg.content);
  }
}

class Response {
  static Future<String> getresponse(String json) async {
    final openAiApiKey = Data.apikey;
    final llm = OpenAI(
      apiKey: openAiApiKey,
      defaultOptions: const OpenAIOptions(temperature: 0.9),
    );
    final LLMResult res = await llm.invoke(
      PromptValue.string(json),
    );
    Map<String, String> output = {"response": res.toString()};

    return jsonEncode(output);
  }
}
