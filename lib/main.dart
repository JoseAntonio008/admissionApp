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
    home: token != null ? HomeScreen() : LoginScreen(),
  ));
}