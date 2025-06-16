import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturningTable extends StatefulWidget {
  final List<dynamic> studentData;
  final Function(List<int>) onDeleteSelected;
  final Function(List<int>, DateTime) onScheduleSelected;
  final List<Map<String, dynamic>> availableScheduleDates; // Modified type
  final Function() onFetchData;

  const ReturningTable({
    Key? key,
    required this.studentData,
    required this.onDeleteSelected,
    required this.onScheduleSelected,
    required this.availableScheduleDates,
    required this.onFetchData,
  }) : super(key: key);

  @override
  ReturningTableState createState() => ReturningTableState();
}

class ReturningTableState extends State<ReturningTable> {
  List<bool> _selectedRows = [];
  List<int> _selectedIds = [];
  DateTime? _selectedDateTime;
  final ScrollController _horizontalScrollController = ScrollController();

  // Pagination state variables
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _firstRowIndex = 0;
  int _currentPage = 0;

  // Search state variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeSelectedRows();
    // Listen for changes in the search text field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(ReturningTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentData != widget.studentData) {
      _initializeSelectedRows();
      // Reset to first page if data changes significantly
      _currentPage = 0;
      _firstRowIndex = 0;
      // Re-apply search filter if data changes
      _filterStudentData();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeSelectedRows() {
    _selectedRows = List.generate(widget.studentData.length, (index) => false);
    _selectedIds = [];
  }

  void _updateSelectedIds() {
    _selectedIds = [];
    // Iterate through the original studentData to find selected IDs
    for (int i = 0; i < _selectedRows.length; i++) {
      if (_selectedRows[i]) {
        _selectedIds.add(widget.studentData[i]['id']);
      }
    }
  }

  // Method to handle search input changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      // Reset to the first page when search query changes
      _currentPage = 0;
      _firstRowIndex = 0;
      _initializeSelectedRows(); // Reset selections
    });
  }

  // Method to filter student data based on search query
  List<dynamic> _filterStudentData() {
    if (_searchQuery.isEmpty) {
      return widget.studentData;
    } else {
      return widget.studentData.where((student) {
        final String studentId = student['id'].toString().toLowerCase();
        final String firstName = student['firstName'].toLowerCase();
        final String lastName = student['lastName'].toLowerCase();
        final String email = student['email'].toLowerCase();

        return studentId.contains(_searchQuery) ||
            firstName.contains(_searchQuery) ||
            lastName.contains(_searchQuery) ||
            email.contains(_searchQuery);
      }).toList();
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
                String? dateTimeString = slot['dateTime'] as String?;
                DateTime? date;
                if (dateTimeString != null) {
                  try {
                    date = DateTime.parse(dateTimeString);
                  } catch (e) {
                    print('Error parsing date: $dateTimeString - $e');
                  }
                }

                String location = slot['location'] as String? ?? 'N/A';
                String description = slot['description'] as String? ?? 'N/A';

                if (date == null) {
                  return Container();
                }

                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                  subtitle: Text('$location - $description'),
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
    final List<dynamic> filteredData = _filterStudentData();

    // Calculate total pages based on filtered data
    final int totalItems = filteredData.length;
    final int totalPages = (totalItems / _rowsPerPage).ceil();

    // Get the current page's data from filtered data
    final List<dynamic> currentPageData = filteredData.sublist(
      _firstRowIndex,
      (_firstRowIndex + _rowsPerPage).clamp(0, totalItems),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            // Changed from Row to Column here
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by ID, Name, or Email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                  height: 10), // Add spacing between search and buttons
              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Align buttons to the right if desired
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        widget.onDeleteSelected(_selectedIds);
                      }
                    },
                    child: const Text('Delete Selected'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _selectDate(context);
                      if (_selectedIds.isNotEmpty &&
                          _selectedDateTime != null) {
                        print(
                            'Scheduled IDs: $_selectedIds at $_selectedDateTime');
                        try {
                          final response = await Apiservice.approveSecond(
                              _selectedIds, _selectedDateTime);
                          Toast.show(context,
                              message: response['message'],
                              backgroundColor: Colors.green);
                          widget.onFetchData();
                        } catch (e) {
                          print(e.toString());
                          Toast.show(context,
                              message: e.toString(),
                              backgroundColor: Colors.red);
                        }
                      }
                    },
                    child: const Text('Schedule'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _horizontalScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Student ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                ],
                rows: currentPageData.asMap().entries.map((entry) {
                  int absoluteIndex = _firstRowIndex + entry.key;
                  dynamic student = entry.value;
                  return DataRow(
                    selected: _selectedRows[absoluteIndex],
                    onSelectChanged: (bool? value) {
                      setState(() {
                        _selectedRows[absoluteIndex] = value!;
                        _updateSelectedIds();
                      });
                    },
                    cells: <DataCell>[
                      DataCell(Text(student['id'].toString())),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  150), // Adjust max width for Name column
                          child: Text(
                            '${student['firstName']} ${student['lastName']}',
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis for overflow
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth:
                                  100, // Adjusted minWidth for better flexibility
                              maxWidth:
                                  250), // Adjusted maxWidth for Email column
                          child: Text(
                            student['email'],
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis for overflow
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Pagination Controls
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage = 0;
                          _firstRowIndex = 0;
                          _initializeSelectedRows(); // Reset selection on page change
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                          _firstRowIndex = _currentPage * _rowsPerPage;
                          _initializeSelectedRows(); // Reset selection on page change
                        });
                      }
                    : null,
              ),
              Text('Page ${_currentPage + 1} of $totalPages'),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _currentPage < totalPages - 1
                    ? () {
                        setState(() {
                          _currentPage++;
                          _firstRowIndex = _currentPage * _rowsPerPage;
                          _initializeSelectedRows(); // Reset selection on page change
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _currentPage < totalPages - 1
                    ? () {
                        setState(() {
                          _currentPage = totalPages - 1;
                          _firstRowIndex = _currentPage * _rowsPerPage;
                          _initializeSelectedRows(); // Reset selection on page change
                        });
                      }
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: _rowsPerPage,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10 per page')),
                  DropdownMenuItem(value: 20, child: Text('20 per page')),
                  DropdownMenuItem(value: 50, child: Text('50 per page')),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _rowsPerPage = newValue;
                      _currentPage = 0; // Reset to first page
                      _firstRowIndex = 0;
                      _initializeSelectedRows(); // Reset selection
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
