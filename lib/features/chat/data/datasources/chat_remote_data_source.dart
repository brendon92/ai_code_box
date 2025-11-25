import 'package:dio/dio.dart';
import '../../../../core/constants.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Stream<String> sendMessage(List<ChatModel> history);
}

class OpenAiRemoteDataSource implements ChatRemoteDataSource {
  final Dio dio;

  OpenAiRemoteDataSource(this.dio);

  @override
  Stream<String> sendMessage(List<ChatModel> history) async* {
    try {
      final response = await dio.post(
        '${Constants.openAiBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.apiKey}',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': history.map((e) => e.toJson()).toList(),
          'stream': true,
        },
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        // Simple parsing logic for SSE (Server-Sent Events)
        // In a real app, use a robust parser
        final String chunkStr = String.fromCharCodes(chunk);
        // This is a simplified example. Real parsing needs to handle partial chunks.
        if (chunkStr.contains('content')) {
           // Extract content logic here
           // For now, we just yield the raw chunk to demonstrate flow
           yield chunkStr; 
        }
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
