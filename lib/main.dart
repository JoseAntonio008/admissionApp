import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/homepage.dart';
import './pages/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("jwt_token");

  runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: token != null ? '/home' : "/login",
  routes: {
    "/login": (context) => LoginScreen(), // Ensure this is present and correct
    '/home': (context) => HomeScreen(),
  },
));
}

// Inside your logout function:
// onTap: () {
//   final authService = AuthService().logout();
//   Navigator.pushReplacementNamed(context, '/login');
// },