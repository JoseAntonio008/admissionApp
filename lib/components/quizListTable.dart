import 'dart:convert';
import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class QuestionTable extends StatefulWidget {
  @override
  _QuestionTableState createState() => _QuestionTableState();
}

class _QuestionTableState extends State<QuestionTable> {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  Set<int> _selectedQuestionIds = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final response = await http
        .get(Uri.parse('http://localhost:5000/api/questions/fetchQuestions'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("Failed to load questions. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions.')),
      );
    }
  }

  void _showChoicesDialog(List<dynamic> choices, int questionId,
      int choiceIndex, dynamic question) {
    // Add question parameter
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choices'),
          content: SingleChildScrollView(
            child: Column(
              children: choices.map<Widget>((choice) {
                final index = choices.indexOf(choice);
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 100),
                            child: Text(choice['text'])),
                      ),
                      if (choice['image'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CachedNetworkImage(
                            imageUrl: choice['image'],
                            width: 100,
                            height: 100,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(), // Loading indicator
                            errorWidget: (context, url, error) => Center(
                                child: Text("Image Failed")), // Error handling
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editChoice(questionId, index, choice),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteChoice(
                            questionId, index, question), //Pass question
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add Choice'),
              onPressed: () {
                Navigator.of(context).pop();
                _addChoice(questionId);
              },
            ),
          ],
        );
      },
    );
  }

  void _addChoice(int questionId) {
    TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Choice'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(labelText: "Choice Text"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the "Add Choice" dialog
                final response = await Apiservice.updateChoice(
                  questionId,
                  0,
                  textController.text,
                  'add',
                );

                if (response.containsKey('error')) {
                  Toast.show(context,
                      message: 'Error: ${response['error']}',
                      backgroundColor: Colors.red);
                  print('Error: ${response['error']}');
                } else {
                  Toast.show(context,
                      message: '${response['message']}',
                      backgroundColor: Colors.green);
                  print('Message: ${response['message']}');
                  _fetchQuestions().then((_) {
                    // Removed the unnecessary second pop() call.
                    final updatedQuestion =
                        _questions.firstWhere((q) => q['id'] == questionId);
                    _showChoicesDialog(updatedQuestion['choices'], questionId,
                        0, updatedQuestion);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editChoice(int questionId, int choiceIndex, dynamic choice) {
    TextEditingController textController =
        TextEditingController(text: choice['text']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Choice'),
          content: TextField(
              controller: textController,
              decoration: InputDecoration(labelText: "New Text")),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop();
                final response = await Apiservice.updateChoice(
                  questionId,
                  choiceIndex,
                  textController.text,
                  'update',
                );

                if (response.containsKey('error')) {
                  Toast.show(context,
                      message: 'Error: ${response['error']}',
                      backgroundColor: Colors.red);
                  print('Error: ${response['error']}');
                } else {
                  Toast.show(context,
                      message: '${response['message']}',
                      backgroundColor: Colors.green);
                  print('Message: ${response['message']}');
                  _fetchQuestions().then((_) {
                    // Close the old dialog first
                    Navigator.of(context).pop(); // Close the old dialog

                    // Reopen the dialog with updated choices
                    final updatedQuestion =
                        _questions.firstWhere((q) => q['id'] == questionId);
                    _showChoicesDialog(updatedQuestion['choices'], questionId,
                        choiceIndex, updatedQuestion);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteChoice(int questionId, int choiceIndex, dynamic question) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete Choice'),
          content: Text('Are you sure you want to delete this choice?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                final response = await Apiservice.updateChoice(
                  questionId,
                  choiceIndex,
                  "hello",
                  'delete',
                );

                if (response.containsKey('error')) {
                  Toast.show(context,
                      message: 'Error: ${response['error']}',
                      backgroundColor: Colors.red);
                  print('Error: ${response['error']}');
                } else {
                  Toast.show(context,
                      message: '${response['message']}',
                      backgroundColor: Colors.green);
                  print('Message: ${response['message']}');
                  _fetchQuestions().then((_) {
                    // Close the old dialog first
                    Navigator.of(context).pop(); // Close the old dialog

                    // Reopen the dialog with updated choices
                    final updatedQuestion =
                        _questions.firstWhere((q) => q['id'] == questionId);
                    _showChoicesDialog(updatedQuestion['choices'], questionId,
                        choiceIndex, updatedQuestion);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content:
              Text('Are you sure you want to delete the selected questions?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                for (int id in _selectedQuestionIds) {
                  final response = await http.delete(
                      Uri.parse('http://localhost:5000/api/questions/$id'));
                  if (response.statusCode != 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Failed to delete question with id $id.')));
                  }
                }
                _selectedQuestionIds.clear();
                _fetchQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  String _indexToLetter(int index) {
    if (index >= 0 && index < 26) {
      return String.fromCharCode('A'.codeUnitAt(0) + index);
    }
    return ''; // Return empty string for invalid indices
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedQuestionIds.isNotEmpty ? _confirmDelete : null,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(child: Text('No questions found.'))
              : Padding(
                  padding: const EdgeInsets.only(left: 100, right: 100),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      // ... (Your DataTable remains the same)
                      columns: [
                        DataColumn(label: Text('Select')),
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Choices')),
                        DataColumn(label: Text('Author')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Correct Answer')),
                      ],
                      rows: _questions.map((question) {
                        final isSelected =
                            _selectedQuestionIds.contains(question['id']);
                        return DataRow(
                          cells: [
                            DataCell(Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    _selectedQuestionIds.add(question['id']);
                                  } else {
                                    _selectedQuestionIds.remove(question['id']);
                                  }
                                });
                              },
                            )),
                            DataCell(Text(question['id'].toString())),
                            DataCell(Text(question['questionTitle'])),
                            DataCell(ElevatedButton(
                              onPressed: () => _showChoicesDialog(
                                  question['choices'],
                                  question['id'],
                                  0,
                                  question), //Pass question.
                              child: Text('Show Choices'),
                            )),
                            DataCell(Text(question['author'])),
                            DataCell(Text(question['category'])),
                            DataCell(Text(
                                _indexToLetter(question['correctAnswer']))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
