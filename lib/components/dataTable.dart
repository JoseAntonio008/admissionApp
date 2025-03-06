import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewStudentTable extends StatefulWidget {
  final List<dynamic> studentData;
  final Function(List<int>) onDeleteSelected;
  final Function(List<int>, DateTime) onScheduleSelected;
  final List<Map<String, dynamic>> availableScheduleDates; // Modified type

  const NewStudentTable({
    Key? key,
    required this.studentData,
    required this.onDeleteSelected,
    required this.onScheduleSelected,
    required this.availableScheduleDates,
  }) : super(key: key);

  @override
  _NewStudentTableState createState() => _NewStudentTableState();
}

class _NewStudentTableState extends State<NewStudentTable> {
  List<bool> _selectedRows = [];
  List<int> _selectedIds = [];
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _initializeSelectedRows();
  }

  @override
  void didUpdateWidget(NewStudentTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentData != widget.studentData) {
      _initializeSelectedRows();
    }
  }

  void _initializeSelectedRows() {
    _selectedRows = List.generate(widget.studentData.length, (index) => false);
    _selectedIds = [];
  }

  void _updateSelectedIds() {
    _selectedIds = [];
    for (int i = 0; i < _selectedRows.length; i++) {
      if (_selectedRows[i]) {
        _selectedIds.add(widget.studentData[i]['id']);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Date'),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.availableScheduleDates.map((slot) { // Modified to slot
                DateTime date = DateTime.parse(slot['dateTime']);
                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                  subtitle: Text('${slot['location']} - ${slot['description']}'), // Display location and description
                  onTap: () {
                    setState(() {
                      _selectedDateTime = date;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 100,top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_selectedIds.isNotEmpty) {
                    widget.onDeleteSelected(_selectedIds);
                  }
                },
                child: const Text('Delete Selected'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _selectDate(context); // Changed to _selectDate
                  if (_selectedIds.isNotEmpty && _selectedDateTime != null) {
                    // widget.onScheduleSelected(_selectedIds, _selectedDateTime!);
                    print('Scheduled IDs: $_selectedIds at $_selectedDateTime');
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Select')),
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Senior HighSchool')),
              DataColumn(label: Text('School Type')),
              DataColumn(label: Text('Year Graudated')),
              DataColumn(label: Text('Awards')),
              DataColumn(label: Text('Actions')),
            ],
            rows: widget.studentData.asMap().entries.map((entry) {
              int index = entry.key;
              dynamic student = entry.value;
              return DataRow(
                cells: <DataCell>[
                  DataCell(Checkbox(
                    value: _selectedRows[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedRows[index] = value!;
                        _updateSelectedIds();
                      });
                    },
                  )),
                  DataCell(Text(student['id'].toString())),
                  DataCell(Text('${student['firstName']} ${student['lastName']}')),
                  DataCell(Text(student['email'])),
                  DataCell(Text(student['shs'])),
                  DataCell(Text(student['schoolType'])),
                  DataCell(Text(student['yearGraduated'])),
                  DataCell(Text(student['awardsReceived'])),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implement edit logic
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Implement delete logic
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        
      ],
    );
  }
}