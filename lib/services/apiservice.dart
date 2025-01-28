import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io';

class Apiservice {
  static String baseUrl = 'http://localhost:4000';

  static Future<dynamic> createMultipleQuiz(dynamic quizData) async {
    try {
      final url = Uri.parse('$baseUrl/api/upload-quiz');
      print(jsonEncode(quizData));
      final response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: jsonEncode({'author': 'jomar', 'question': quizData}));
      final message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['message']);
      }
      return message['message'];
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
