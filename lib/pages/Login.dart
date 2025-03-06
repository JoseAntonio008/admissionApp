import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:admission/services/authService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async{
    AuthService authService = AuthService();
    Map<String, dynamic>? decodedToken = await authService.getDecodedToken();
    if (decodedToken == null) {
      print("empty token");
    }else{
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await Apiservice.login(
          _usernameController.text, _passwordController.text);

      print(response);
      if (response['message'] == "login successful") {
        Toast.show(context,
            message: response['message'], backgroundColor: Colors.green);
        print('token here ${response['token']}');
        String token = response['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", token);
        print("Token stored in SharedPreferences: $token");
        Navigator.pushReplacementNamed(context, '/home');

      }
      
      Toast.show(context, message: response['message'],backgroundColor: Colors.orange);
    } catch (e) {
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
