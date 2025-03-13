import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordsTable extends StatefulWidget {
  @override
  _RecordsTableState createState() => _RecordsTableState();
}

class _RecordsTableState extends State<RecordsTable> {
  List<Map<String, dynamic>> records = [];
  Set<int> selectedIds = Set<int>();
  final String apiUrl = "http://localhost:5000/api/schedule/fetch-sched";

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        records =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  void toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  Future<void> updateDateTime() async {
    if (selectedIds.isEmpty) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    DateTime newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final response = await http.put(
      Uri.parse("$apiUrl/update"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "ids": selectedIds.toList(),
        "newDateTime": newDateTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      fetchRecords();
      setState(() {
        selectedIds.clear();
      });
    }
  }

  Future<void> addRecord() async {
    TextEditingController locationController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location")),
            TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final response = await http.post(
                Uri.parse("$apiUrl/add"),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  "dateTime": DateTime.now().toIso8601String(),
                  "location": locationController.text,
                  "description": descriptionController.text,
                  "status": "active",
                }),
              );

              if (response.statusCode == 200) {
                fetchRecords();
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Records Table"), actions: [
        IconButton(
          icon: Icon(Icons.update),
          onPressed: updateDateTime,
        ),
      ]),
      body: records.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Text("Select")),
                    DataColumn(label: Text("DateTime")),
                    DataColumn(label: Text("Location")),
                    DataColumn(label: Text("Description")),
                    DataColumn(label: Text("Status")),
                  ],
                  rows: records
                      .map(
                        (record) => DataRow(
                          selected: selectedIds.contains(record['id']),
                          onSelectChanged: (selected) =>
                              toggleSelection(record['id']),
                          cells: [
                            DataCell(Checkbox(
                              value: selectedIds.contains(record['id']),
                              onChanged: (value) =>
                                  toggleSelection(record['id']),
                            )),
                            DataCell(Text(record['dateTime'].toString())),
                            DataCell(Text(record['location'])),
                            DataCell(Text(record['description'])),
                            DataCell(Text(record['status'])),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRecord,
        child: Icon(Icons.add),
      ),
    );
  }
}
