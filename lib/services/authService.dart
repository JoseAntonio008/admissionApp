import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>?> getDecodedToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token");
    if (token == null) return null;

    try {
      final jwt = JWT.decode(token);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(jwt.payload['exp'] * 1000); // Convert exp to DateTime
      final now = DateTime.now();

      if (expirationDate.isBefore(now)) {
        print("Token expired");
        await prefs.remove("jwt_token");
        return null;
      }

      print(jwt.payload);
      return jwt.payload;
    } catch (e) {
      print("Invalid Token: $e");
      await prefs.remove("jwt_token");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }
}