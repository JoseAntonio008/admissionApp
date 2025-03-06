import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Apiservice {
  static String baseUrl = 'http://localhost:5000';

  static Future<dynamic> createMultipleQuiz(dynamic quizData) async {
    try {
      final url = Uri.parse('$baseUrl/api/upload-quiz');
      //
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

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/admin/login');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': username, 'password': password}));
      final Map<String, dynamic> message = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return {'message': 'An error occured', 'error': message['message']};
      }
      if (!message.containsKey('token')) {
        return {'message': message['message']};
      }
      
      return {'message': message['message'], 'token': message['token']};
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        return {'message':'Network Problem'};
      }
      return {'message': '${e.toString()}'};
    }
  }

  static Future<dynamic> fetchTotalApplicants() async {
    try {
      final url = Uri.parse('$baseUrl/api/dashboard/totalApplicants');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['message']);
      }
      return message['data']['count'];
    } catch (e) {
      if (e.toString() == "Exception: Invalid token") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("jwt_token");
      }
      return e;
    }
  }
  
  static Future<dynamic> fetchNew() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/fetchNew');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['message']);
      }
      if (message['data']==null) {
        return message['message'];
      }
      print(message);
      return {'message':message['message'],'data':message['data'],'availableSlots':message['availableSlots']};
    } catch (e) {
      return e.toString();
    }
  }
}
