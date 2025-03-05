import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';

class ResponsiveContainers extends StatefulWidget {
  @override
  _ResponsiveContainersState createState() => _ResponsiveContainersState();
}

class _ResponsiveContainersState extends State<ResponsiveContainers> {
  late Future<dynamic> _totalApplicantsFuture;

  @override
  void initState() {
    super.initState();
    _totalApplicantsFuture = Apiservice.fetchTotalApplicants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.only(left: constraints.maxWidth * .05, right: 20),
            child: SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Wrap(
                direction: Axis.horizontal,
                children: [
                  FutureBuilder<dynamic>(
                    future: _totalApplicantsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildContainer(
                            context, constraints, 'Total Applicants', 'Loading...');
                      } else if (snapshot.hasError) {
                        return buildContainer(
                            context, constraints, 'Total Applicants', 'Error');
                      } else {
                        return buildContainer(
                            context, constraints, 'Total Applicants', snapshot.data.toString());
                      }
                    },
                  ),
                  SizedBox(
                      width: constraints.maxWidth > 200 ? 10 : 0), // conditional SizedBox
                  buildContainer(context, constraints, 'Scheduled Exams', '200'),
                  SizedBox(
                      width: constraints.maxWidth > 200 ? 10 : 0), // conditional SizedBox
                  buildContainer(context, constraints, 'Exam Results', '300'),
                  SizedBox(
                      width: constraints.maxWidth > 200 ? 10 : 0), // conditional SizedBox
                  buildContainer(context, constraints, 'Upcoming Exams', '300'),
                  SizedBox(
                      width: constraints.maxWidth > 200 ? 10 : 0), // conditional SizedBox
                  buildContainer(context, constraints, 'Recent Exam Results', '300'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildContainer(
      BuildContext context, BoxConstraints constraints, String text, String data) {
    double containerSizedHeight = 150; // Default height
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth > 693
          ? screenWidth * 0.27
          : screenWidth, //conditional width.
      height: containerSizedHeight,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(data, style: TextStyle(color: Colors.white, fontSize: 18))
          ],
        ),
      ),
    );
  }
}