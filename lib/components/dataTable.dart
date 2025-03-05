import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class NewStudentTable extends StatefulWidget {
  final List<dynamic> studentData;
  final Function(List<int>) onDeleteSelected;
  final Function(List<int>, DateTime) onScheduleSelected;

  const NewStudentTable({
    Key? key,
    required this.studentData,
    required this.onDeleteSelected,
    required this.onScheduleSelected,
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Select')),
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('SHS')),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                await _selectDateTime(context);
                if (_selectedIds.isNotEmpty && _selectedDateTime != null) {
                  widget.onScheduleSelected(_selectedIds, _selectedDateTime!);
                  print('Scheduled IDs: $_selectedIds at $_selectedDateTime');
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ],
    );
  }
}