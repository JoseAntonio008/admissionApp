import 'package:admission/components/Toast.dart';
import 'package:admission/components/admissionTable.dart';
import 'package:admission/components/dataTable.dart';
import 'package:admission/components/returningTable.dart';
import 'package:admission/components/secondTable.dart';
import 'package:admission/components/transfereeTable.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
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
  List<dynamic> _TransfereeStudentData = [];
  List<dynamic> _SecondStudentData = [];
  List<dynamic> _ReturningStudentData = [];
  List<dynamic> _AdmissionStudentData = [];
  List<Map<String, dynamic>> _availableScheduleDates = []; // Modified type

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final response = await Apiservice.fetchNew();
    final responseTransferee = await Apiservice.fetchTransfree();
    final responseSecond = await Apiservice.fetchSecond();
    final responseReturning = await Apiservice.fetchReturning();
    final responseAdmission = await Apiservice.fetchAdmission();
    print(response['data']);

    List<Map<String, dynamic>> availableSlots = [];
    if (response['availableSlots'] != null) {
      availableSlots = List<Map<String, dynamic>>.from(
          response['availableSlots']); // convert to list of maps
    }

    setState(() {
      _TransfereeStudentData = responseTransferee['data'];
      _studentData = response['data'];
      _SecondStudentData = responseSecond['data'];
      _ReturningStudentData = responseReturning['data'];
      _AdmissionStudentData = responseAdmission['data'];
      _availableScheduleDates = availableSlots; // Update available dates
    });
  }

  void _deleteSelected(List<int> ids) async {
    print('Delete IDs: $ids');
    try {
      final response = await Apiservice.archiveNew(ids);
      print(response);
      Toast.show(context,
          message: response['message'], backgroundColor: Colors.green);
      _fetchStudentData();
    } catch (e) {
      print(e.toString());
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
      _fetchStudentData();
    }
    // Implement delete API call here
  }

  void _deleteSelectedAdmission(List<int> ids) async {
    print('Delete IDs: $ids');
    try {
      final response = await Apiservice.archiveAdmission(ids);
      print(response);
      Toast.show(context,
          message: response['message'], backgroundColor: Colors.green);
      _fetchStudentData();
    } catch (e) {
      print(e.toString());
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
      _fetchStudentData();
    }
    // Implement delete API call here
  }

  void _deleteSelectedTransferee(List<int> ids) async {
    print('Delete IDs: $ids');
    try {
      final response = await Apiservice.archiveTransferee(ids);
      print(response);
      Toast.show(context,
          message: response['message'], backgroundColor: Colors.green);
      _fetchStudentData();
    } catch (e) {
      print(e.toString());
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
      _fetchStudentData();
    }
    // Implement delete API call here
  }

  void _deleteSelectedSecond(List<int> ids) async {
    print('Delete IDs: $ids');
    try {
      final response = await Apiservice.archiveSecond(ids);
      print(response);
      Toast.show(context,
          message: response['message'], backgroundColor: Colors.green);
      _fetchStudentData();
    } catch (e) {
      print(e.toString());
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
      _fetchStudentData();
    }
    // Implement delete API call here
  }

  void _deleteSelectedSReturning(List<int> ids) async {
    print('Delete IDs: $ids');
    try {
      final response = await Apiservice.archiveReturning(ids);
      print(response);
      Toast.show(context,
          message: response['message'], backgroundColor: Colors.green);
      _fetchStudentData();
    } catch (e) {
      print(e.toString());
      Toast.show(context, message: e.toString(), backgroundColor: Colors.red);
      _fetchStudentData();
    }
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
            Tab(text: 'Transferee Student'),
            Tab(text: 'Returning Student'),
            Tab(text: '2nd Degree Taker'),
            Tab(text: 'Admission Takers'),
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
            availableScheduleDates: _availableScheduleDates,
            onFetchData: _fetchStudentData, // Pass the dates
          ),
          TransfereeTable(
            studentData: _TransfereeStudentData,
            onDeleteSelected: _deleteSelectedTransferee,
            onScheduleSelected: _scheduleSelected,
            availableScheduleDates: _availableScheduleDates,
            onFetchData: _fetchStudentData, // Pass the dates
          ),
          ReturningTable(
            studentData: _ReturningStudentData,
            onDeleteSelected: _deleteSelectedSReturning,
            onScheduleSelected: _scheduleSelected,
            availableScheduleDates: _availableScheduleDates,
            onFetchData: _fetchStudentData, // Pass the dates
          ),
          SecondTable(
            studentData: _SecondStudentData,
            onDeleteSelected: _deleteSelected,
            onScheduleSelected: _scheduleSelected,
            availableScheduleDates: _availableScheduleDates,
            onFetchData: _fetchStudentData, // Pass the dates
          ),
          AdmissionTable(
            studentData: _AdmissionStudentData,
            onDeleteSelected: _deleteSelectedAdmission,
            onScheduleSelected: _scheduleSelected,
            availableScheduleDates: _availableScheduleDates,
            onFetchData: _fetchStudentData, // Pass the dates
          ),
        ],
      ),
    );
  }
}
