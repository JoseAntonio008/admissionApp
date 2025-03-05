import 'package:admission/pages/Quiz.dart';
import 'package:admission/pages/admission.dart';
import 'package:admission/pages/dashboard.dart';
import 'package:admission/pages/schedule.dart';
import 'package:admission/services/authService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Loading...";
  int userID = 0;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }
  final List<Widget> _dashboard = [
    Padding(
      padding: const EdgeInsets.only(bottom: 0,left: 50,right: 10,top: 10),
      child:  Center(child: ResponsiveContainers()),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: 0,left: 50,right: 10,top: 10),
      child: Center(child: Schedule(),),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: 0,left: 50,right: 10,top: 10),
      child: Center(child: AdmissionState(),),
    ),
    
  ];
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
    Navigator.pop(context); // Close the drawer
  }

  Future<void> loadUserInfo() async {
    AuthService authService = AuthService();
    Map<String, dynamic>? decodedToken = await authService.getDecodedToken();

    if (decodedToken != null) {
      setState(() {
        userID = decodedToken['userID'];
        fullName =
            "${decodedToken['fname']} ${decodedToken['mname']} ${decodedToken['lname']}";
      });
    } else {
      setState(() {
        fullName = "User not found";
        userID = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(fullName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text("User ID: $userID"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
            ),
            
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                //show page for home
                _onItemSelected(0); // Closes the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Schedule'),
              onTap: () {
                _onItemSelected(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Admission'),
              onTap: () {
                _onItemSelected(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart_sharp),
              title: Text('Test Results'),
              onTap: () {
                _onItemSelected(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_to_photos_rounded),
              title: Text('Manage Quiz'),
              onTap: () {
                _onItemSelected(4);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                final authService = AuthService().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Center(child: _dashboard[_selectedIndex],
      ),
    );
  }
}
