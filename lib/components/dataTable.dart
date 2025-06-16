import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewStudentTable extends StatefulWidget {
  final List<dynamic> studentData;
  final Function(List<int>) onDeleteSelected;
  final Function(List<int>, DateTime) onScheduleSelected;
  final List<Map<String, dynamic>> availableScheduleDates; // Modified type
  final Function() onFetchData;

  const NewStudentTable({
    Key? key,
    required this.studentData,
    required this.onDeleteSelected,
    required this.onScheduleSelected,
    required this.availableScheduleDates,
    required this.onFetchData,
  }) : super(key: key);

  @override
  _NewStudentTableState createState() => _NewStudentTableState();
}

class _NewStudentTableState extends State<NewStudentTable> {
  List<bool> _selectedRows = [];
  List<int> _selectedIds = [];
  DateTime? _selectedDateTime;

  // 1. Create a ScrollController for the horizontal scrollable area
  final ScrollController _horizontalScrollController = ScrollController();

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

  @override
  void dispose() {
    // 2. Dispose the scroll controller when the widget is removed
    _horizontalScrollController.dispose();
    super.dispose();
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
              children: widget.availableScheduleDates.map((slot) {
                // Modified to slot
                DateTime date = DateTime.parse(slot['dateTime']);
                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                  subtitle: Text(
                      '${slot['location']} - ${slot['description']}'), // Display location and description
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
    // double screenWidth = MediaQuery.of(context).size.width; // Not used in this snippet, can be removed if not used elsewhere

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 10),
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
                    print('Scheduled IDs: $_selectedIds at $_selectedDateTime');
                    try {
                      final response = await Apiservice.approveNew(
                          _selectedIds, _selectedDateTime);
                      Toast.show(context,
                          message: response['message'],
                          backgroundColor: Colors.green);
                      widget.onFetchData();
                    } catch (e) {
                      print(e.toString());
                      Toast.show(context,
                          message: e.toString(), backgroundColor: Colors.red);
                    }
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          ),
        ),
        Expanded(
          // Use Expanded to ensure the SingleChildScrollView takes available vertical space
          child: widget.studentData.isEmpty
              ? const Center(
                  child: Text(
                    'No transfer students to display.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Scrollbar(
                  thumbVisibility: true,
                  // 3. Assign the scroll controller to the Scrollbar
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // 4. Assign the same scroll controller to the SingleChildScrollView
                    controller: _horizontalScrollController,
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
                        // DataColumn(label: Text('Actions')), // Commented out
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
                            DataCell(Text(
                                '${student['firstName']} ${student['lastName']}')),
                            DataCell(Text(student['email'])),
                            DataCell(Text(student['shs'])),
                            DataCell(Text(student['schoolType'])),
                            DataCell(Text(student['yearGraduated'])),
                            DataCell(Text(student['awardsReceived'])),
                            // DataCell( // Commented out actions
                            //   Row(
                            //     children: [
                            //       IconButton(
                            //         icon: const Icon(Icons.edit),
                            //         onPressed: () {
                            //           // Implement edit logic
                            //         },
                            //       ),
                            //       IconButton(
                            //         icon: const Icon(Icons.delete),
                            //         onPressed: () {
                            //           // Implement delete logic
                            //         },
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
