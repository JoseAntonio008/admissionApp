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
        return {'message': 'Network Problem'};
      }
      return {'message': '${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateChoice(
      int questionId, int choiceIndex, String newText, String action) async {
    try {
      final url = Uri.parse('$baseUrl/api/questions/update-choice/$questionId');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");
      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'choiceIndex': choiceIndex,
            'newText': newText,
            'action': action
          }));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        return {'error': message['error']}; // Return error message in a map
      }
      return {'message': message['message']};
    } catch (e) {
      return {'error': e.toString()}; // Return exception as a string in a map
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

  static Future<dynamic> fetchTotalSchedules() async {
    try {
      final url = Uri.parse('$baseUrl/api/dashboard/totalSchedules');
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
      if (message['data'] == null) {
        return message['message'];
      }
      print(message);
      return {
        'message': message['message'],
        'data': message['data'],
        'availableSlots': message['availableSlots']
      };
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> fetchTransfree() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/fetchTransferee');
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
      if (message['data'] == null) {
        return message['message'];
      }
      print(message);
      return {
        'message': message['message'],
        'data': message['data'],
        'availableSlots': message['availableSlots']
      };
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> fetchSecond() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/fetchSecond');
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
      if (message['data'] == null) {
        return message['message'];
      }
      print(message);
      return {
        'message': message['message'],
        'data': message['data'],
        'availableSlots': message['availableSlots']
      };
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> fetchAdmission() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/fetchAdmission');
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
      if (message['data'] == null) {
        return message['message'];
      }
      print(message);
      return {
        'message': message['message'],
        'data': message['data'],
        'availableSlots': message['availableSlots']
      };
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> fetchReturning() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/fetchReturning');
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
      if (message['data'] == null) {
        return message['message'];
      }
      print(message);
      return {
        'message': message['message'],
        'data': message['data'],
        'availableSlots': message['availableSlots']
      };
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> archiveNew(List<int> id) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/archive-new');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['error']);
      }
      return {'message': message['message']};
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> archiveReturning(List<int> id) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/archive-returning');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['error']);
      }
      return {'message': message['message']};
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> archiveAdmission(List<int> id) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/archive-admission');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['error']);
      }
      return {'message': message['message']};
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> archiveTransferee(List<int> id) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/archive-transferee');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['error']);
      }
      return {'message': message['message']};
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> archiveSecond(List<int> id) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/archive-second');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}));
      final Map<String, dynamic> message = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(message['error']);
      }
      return {'message': message['message']};
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> approveNew(
      List<int> id, DateTime? examSchedule) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/approve-new');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'examSchedule': examSchedule?.toIso8601String()
          })); // Convert DateTime to String
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (responseBody.containsKey('error')) {
          throw Exception(
              responseBody['error'].toString()); // Ensure error is a String
        } else {
          throw Exception("API Error: ${response.statusCode}");
        }
      }

      if (responseBody.containsKey('message')) {
        return {
          'message': responseBody['message'].toString()
        }; // Ensure message is a String
      } else {
        return {'message': "Success"};
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> changeSchedule(
      List<int> id, DateTime? examSchedule) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/changeSchedule');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'examSchedule': examSchedule?.toIso8601String()
          })); // Convert DateTime to String
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (responseBody.containsKey('error')) {
          throw Exception(
              responseBody['error'].toString()); // Ensure error is a String
        } else {
          throw Exception("API Error: ${response.statusCode}");
        }
      }

      if (responseBody.containsKey('message')) {
        return {
          'message': responseBody['message'].toString()
        }; // Ensure message is a String
      } else {
        return {'message': "Success"};
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> approveTransferee(
      List<int> id, DateTime? examSchedule) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/approve-transferee');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'examSchedule': examSchedule?.toIso8601String()
          })); // Convert DateTime to String
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (responseBody.containsKey('error')) {
          throw Exception(
              responseBody['error'].toString()); // Ensure error is a String
        } else {
          throw Exception("API Error: ${response.statusCode}");
        }
      }

      if (responseBody.containsKey('message')) {
        return {
          'message': responseBody['message'].toString()
        }; // Ensure message is a String
      } else {
        return {'message': "Success"};
      }
    } catch (e) {
      return e.toString();
    }
  }

  static Future<dynamic> approveSecond(
      List<int> id, DateTime? examSchedule) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/approve-second');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'examSchedule': examSchedule?.toIso8601String()
          })); // Convert DateTime to String
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        if (responseBody.containsKey('error')) {
          throw Exception(
              responseBody['error'].toString()); // Ensure error is a String
        } else {
          throw Exception("API Error: ${response.statusCode}");
        }
      }

      if (responseBody.containsKey('message')) {
        return {
          'message': responseBody['message'].toString()
        }; // Ensure message is a String
      } else {
        return {'message': "Success"};
      }
    } catch (e) {
      return e.toString();
    }
  }
}
