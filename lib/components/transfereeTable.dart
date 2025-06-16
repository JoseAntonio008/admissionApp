import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransfereeTable extends StatefulWidget {
  final List<dynamic> studentData;
  final Function(List<int>) onDeleteSelected;
  final Function(List<int>, DateTime) onScheduleSelected;
  final List<Map<String, dynamic>> availableScheduleDates; // Modified type
  final Function() onFetchData;

  const TransfereeTable({
    Key? key,
    required this.studentData,
    required this.onDeleteSelected,
    required this.onScheduleSelected,
    required this.availableScheduleDates,
    required this.onFetchData,
  }) : super(key: key);

  @override
  _TransfereeTableState createState() => _TransfereeTableState();
}

class _TransfereeTableState extends State<TransfereeTable> {
  List<bool> _selectedRows = [];
  List<int> _selectedIds = [];
  DateTime? _selectedDateTime;

  // ScrollController for the horizontal scrollable area of the DataTable
  final ScrollController _horizontalScrollController = ScrollController();

  // TextEditingController for the search input field
  final TextEditingController _searchController = TextEditingController();
  // Variable to store the current search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeSelectedRows();
    // Add a listener to the search controller to update the filter
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(TransfereeTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize selected rows if the student data changes
    if (oldWidget.studentData != widget.studentData) {
      _initializeSelectedRows();
      // Also reset search if new data comes in, or keep it if desired
      _searchController.clear();
      _searchQuery = '';
    }
  }

  @override
  void dispose() {
    // Dispose both scroll and search controllers to prevent memory leaks
    _horizontalScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Called when the search input changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _initializeSelectedRows(); // Re-initialize selections for filtered data
    });
  }

  // Initializes the selectedRows list based on current student data length
  void _initializeSelectedRows() {
    _selectedRows = List.generate(widget.studentData.length, (index) => false);
    _selectedIds = [];
  }

  // Updates the list of selected IDs based on the currently selected rows
  void _updateSelectedIds() {
    _selectedIds = [];
    final filteredData = _filteredStudentData; // Use filtered data for IDs
    for (int i = 0; i < _selectedRows.length; i++) {
      if (_selectedRows[i] && i < filteredData.length) {
        // Ensure index is within bounds
        final idValue = filteredData[i]['id'];
        // Safely parse the 'id' to an integer.
        // If idValue is an int, add it directly.
        // If idValue is a String, try to parse it. If parsing fails (e.g., empty string), it will be null.
        // Only add if the parsed value is not null.
        if (idValue is int) {
          _selectedIds.add(idValue);
        } else if (idValue is String) {
          final parsedId = int.tryParse(idValue);
          if (parsedId != null) {
            _selectedIds.add(parsedId);
          }
        }
      }
    }
  }

  // Getter to provide filtered student data based on search query
  List<dynamic> get _filteredStudentData {
    if (_searchQuery.isEmpty) {
      return widget.studentData;
    }
    final query = _searchQuery.toLowerCase();
    return widget.studentData.where((student) {
      final firstName = (student['firstName'] as String? ?? '').toLowerCase();
      final lastName = (student['lastName'] as String? ?? '').toLowerCase();
      final email = (student['email'] as String? ?? '').toLowerCase();
      final id = (student['id'] as dynamic)?.toString().toLowerCase() ??
          ''; // Convert ID to string for searching

      return firstName.contains(query) ||
          lastName.contains(query) ||
          email.contains(query) ||
          id.contains(query);
    }).toList();
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
    final displayedStudentData = _filteredStudentData;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search students',
              hintText: 'Enter name, email, or ID',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
            ),
          ),
        ),
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
              const SizedBox(width: 10), // Add some spacing
              ElevatedButton(
                onPressed: () async {
                  await _selectDate(context); // Changed to _selectDate
                  if (_selectedIds.isNotEmpty && _selectedDateTime != null) {
                    print('Scheduled IDs: $_selectedIds at $_selectedDateTime');
                    try {
                      final response = await Apiservice.approveTransferee(
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
          child: displayedStudentData.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No transfer students to display.'
                        : 'No results found for "${_searchQuery}".',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Scrollbar(
                  thumbVisibility: true,
                  // Assign the scroll controller to the Scrollbar
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Assign the same scroll controller to the SingleChildScrollView
                    controller: _horizontalScrollController,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Select')),
                        DataColumn(label: Text('Student ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('College')),
                        DataColumn(label: Text('School Type')),
                        DataColumn(label: Text('Highest Attained Year')),
                        DataColumn(label: Text('Awards')),
                      ],
                      rows: displayedStudentData.asMap().entries.map((entry) {
                        int index = entry.key;
                        dynamic student = entry.value;
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Checkbox(
                              value: _selectedRows.length > index
                                  ? _selectedRows[index]
                                  : false, // Check bounds
                              onChanged: (bool? value) {
                                setState(() {
                                  if (_selectedRows.length > index) {
                                    // Check bounds before updating
                                    _selectedRows[index] = value!;
                                  }
                                  _updateSelectedIds();
                                });
                              },
                            )),
                            // Ensure 'id' is always displayed as a string
                            DataCell(Text(student['id']?.toString() ?? '')),
                            DataCell(Text(
                                '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}')),
                            DataCell(Text(student['email'] ?? '')),
                            DataCell(Text(student['nameCollege'] ?? '')),
                            DataCell(Text(student['schoolTypeCollege'] ?? '')),
                            DataCell(Text(
                                student['highestAttainedYear']?.toString() ??
                                    '')),
                            DataCell(Text(student['awardsReceived'] ?? '')),
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
