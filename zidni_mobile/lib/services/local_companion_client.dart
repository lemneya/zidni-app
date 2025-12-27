import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Client for communicating with the local companion server.
/// Provides /health, /stt, and /llm endpoints.
class LocalCompanionClient {
  final String baseUrl;
  final Duration timeout;

  LocalCompanionClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  /// Check if the companion server is healthy and reachable.
  /// Returns true if /health returns 200 OK.
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send audio data to /stt endpoint for transcription.
  /// Returns the transcript string or null on failure.
  Future<String?> transcribeAudio(Uint8List audioData) async {
    try {
      final uri = Uri.parse('$baseUrl/stt');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'audio',
        audioData,
        filename: 'audio.wav',
      ));

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['transcript'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send audio file path to /stt endpoint for transcription.
  /// Returns the transcript string or null on failure.
  Future<String?> transcribeAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final audioData = await file.readAsBytes();
      return transcribeAudio(audioData);
    } catch (e) {
      return null;
    }
  }

  /// Call /llm endpoint to generate text.
  /// Used for follow-up template generation when offline.
  Future<LlmResponse?> generateText({
    required String prompt,
    String? systemPrompt,
    int maxTokens = 1024,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/llm');
      final body = jsonEncode({
        'prompt': prompt,
        if (systemPrompt != null) 'system_prompt': systemPrompt,
        'max_tokens': maxTokens,
      });

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return LlmResponse(
          text: json['text'] as String,
          tokensUsed: json['tokens_used'] as int? ?? 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate Arabic follow-up template using local LLM.
  Future<String?> generateArabicFollowup({
    required String folderName,
    required String transcript,
    String? category,
    String? boothHall,
  }) async {
    final prompt = '''Generate a professional Arabic business follow-up message for WhatsApp.

Supplier/Folder: $folderName
${category != null ? 'Category: $category' : ''}
${boothHall != null ? 'Booth/Hall: $boothHall' : ''}

Meeting Notes:
$transcript

Write a warm, professional follow-up in Arabic that:
1. Thanks them for the meeting
2. References key points from the notes
3. Expresses interest in continuing the discussion
4. Asks about next steps

Output only the Arabic message, no explanations.''';

    final response = await generateText(prompt: prompt);
    return response?.text;
  }

  /// Generate Chinese follow-up template using local LLM.
  Future<String?> generateChineseFollowup({
    required String folderName,
    required String transcript,
    String? category,
    String? boothHall,
  }) async {
    final prompt = '''Generate a professional Chinese business follow-up message for WeChat.

Supplier/Folder: $folderName
${category != null ? 'Category: $category' : ''}
${boothHall != null ? 'Booth/Hall: $boothHall' : ''}

Meeting Notes:
$transcript

Write a warm, professional follow-up in Simplified Chinese that:
1. Thanks them for the meeting
2. References key points from the notes
3. Expresses interest in continuing the discussion
4. Asks about next steps

Output only the Chinese message, no explanations.''';

    final response = await generateText(prompt: prompt);
    return response?.text;
  }
}

/// Response from the /llm endpoint.
class LlmResponse {
  final String text;
  final int tokensUsed;

  LlmResponse({
    required this.text,
    required this.tokensUsed,
  });
}
