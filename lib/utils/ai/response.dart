// ignore_for_file: avoid_print, unused_element

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

// This is a reference class to show the input and output structure
class Response {
  Future<String> getresponse(String message) async {
    String out = "";
    final openAiApiKey = Data.apikey;
    final llm = ChatOpenAI(
      apiKey: openAiApiKey,
      defaultOptions: const ChatOpenAIOptions(
        model: 'gpt-4o-mini',
      ),
    );

    const template = '''
I want you to act as a productivity assistant and be a friend with user.
this is user data {message}
''';
    final promptTemplate = PromptTemplate.fromTemplate(template);
    final prompt = promptTemplate.format({'message': message});
    Data.chatmessages.insert(0, ChatMessage.system(prompt));
    try {
      final res = await llm.invoke(
        PromptValue.chat(Data.chatmessages),
      );
      out = res.outputAsString;
      Data.chatmessages.insert(0, ChatMessage.ai(out));
    } catch (e) {
      out =
          "I am sorry, I am not able to understand your query due to $e. Please try again.";
    }

    return out;
  }

  Future<Map<String, dynamic>> formatresponse(String message) async {
    String response = await getresponse(message);
    Map<String, dynamic> videos = {
      "videoId": "video1",
      "title": "First Video",
      "videoDescription": "https://example.com/video1"
    };

    Map<String, dynamic> output = {
      "response": [response],
      "videos": videos,
      "notification": {"title": "This is title", "message": "Message"},
    };
    return output;
  }
}
