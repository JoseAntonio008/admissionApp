import 'package:admission/components/dataTable.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Admission extends StatelessWidget {
  const Admission({super.key});

  @override
  Widget build(BuildContext context) {
    return AdmissionState();
  }
}

class AdmissionState extends StatefulWidget {
  const AdmissionState({super.key});

  @override
  State<AdmissionState> createState() => _AdmissionStateState();
}

class _AdmissionStateState extends State<AdmissionState>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _studentData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final response = await Apiservice.fetchNew();
    print(response['data']);
    setState(() {
      _studentData = response['data'];
    });
  }

  void _deleteSelected(List<int> ids) {
    print('Delete IDs: $ids');
    // Implement delete API call here
  }

  void _scheduleSelected(List<int> ids, DateTime dateTime) {
    print('Scheduled IDs: $ids at $dateTime');
    // Implement schedule API call here
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Student'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
            Tab(text: 'Tab 4'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewStudentTable(
            studentData: _studentData,
            onDeleteSelected: _deleteSelected,
            onScheduleSelected: _scheduleSelected,
          ),
          const Center(child: Text('Content of Tab 2')),
          const Center(child: Text('Content of Tab 3')),
          const Center(child: Text('Content of Tab 4')),
        ],
      ),
    );
  }
}