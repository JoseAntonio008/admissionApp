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

  void _showChoicesDialog(
      List<dynamic> choices, int questionId, dynamic question) {
    // Removed choiceIndex parameter from here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choices'),
          content: SingleChildScrollView(
            child: Column(
              children: choices.map<Widget>((choice) {
                final index = choices.indexOf(choice);
                // Determine if this choice is the correct answer based on the question's 'correctAnswer' field
                // Assuming 'correctAnswer' in your question data is the index of the correct choice
                final isCorrectChoice = question['correctAnswer'] == index;

                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Text(choice['text']),
                        ),
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
                      // Correct Answer Indicator
                      if (isCorrectChoice)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.check_circle, color: Colors.green),
                        ),
                      // Select as Correct Button
                      IconButton(
                        icon: Icon(Icons.star,
                            color: isCorrectChoice ? Colors.amber : Colors.grey),
                        onPressed: () {
                          _selectCorrectChoice(questionId, index);
                          Navigator.of(context).pop(); // Close dialog after selection
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editChoice(questionId, index, choice),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _deleteChoice(questionId, index, question),
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
                  0, // Assuming index doesn't matter for add, or you'll determine it on backend
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
                  await _fetchQuestions(); // Refresh questions after adding
                  // Reopen the choices dialog with updated data
                  final updatedQuestion = _questions.firstWhere(
                      (q) => q['id'] == questionId,
                      orElse: () => null); // Use orElse for safety

                  if (updatedQuestion != null) {
                    _showChoicesDialog(
                        updatedQuestion['choices'], questionId, updatedQuestion);
                  }
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
                  await _fetchQuestions(); // Refresh questions after editing
                  // Reopen the dialog with updated choices
                  final updatedQuestion = _questions.firstWhere(
                      (q) => q['id'] == questionId,
                      orElse: () => null); // Use orElse for safety

                  if (updatedQuestion != null) {
                    _showChoicesDialog(updatedQuestion['choices'], questionId,
                        updatedQuestion); // Pass updated question
                  }
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
                  "hello", // This "hello" might not be needed for delete operation
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
                  await _fetchQuestions(); // Refresh questions after deleting
                  // Reopen the dialog with updated choices
                  final updatedQuestion = _questions.firstWhere(
                      (q) => q['id'] == questionId,
                      orElse: () => null); // Use orElse for safety

                  if (updatedQuestion != null) {
                    _showChoicesDialog(updatedQuestion['choices'], questionId,
                        updatedQuestion); // Pass updated question
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // New function to handle selecting the correct choice
  void _selectCorrectChoice(int questionId, int selectedChoiceIndex) async {
    final response = await Apiservice.updateCorrectAnswer(
      questionId,
      selectedChoiceIndex,
    );

    if (response.containsKey('error')) {
      Toast.show(context,
          message: 'Error: ${response['error']}', backgroundColor: Colors.red);
      print('Error selecting correct choice: ${response['error']}');
    } else {
      Toast.show(context,
          message: '${response['message']}', backgroundColor: Colors.green);
      print('Message: ${response['message']}');
      await _fetchQuestions(); // Refresh questions to update UI
      // Reopen the dialog with updated choices and correct answer indicator
      final updatedQuestion = _questions.firstWhere(
          (q) => q['id'] == questionId,
          orElse: () => null);

      if (updatedQuestion != null) {
        _showChoicesDialog(
            updatedQuestion['choices'], questionId, updatedQuestion);
      }
    }
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
                                    _selectedQuestionIds
                                        .remove(question['id']);
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
                                  question), // Pass question without choiceIndex
                              child: Text('Show Choices'),
                            )),
                            DataCell(Text(question['author'])),
                            DataCell(Text(question['category'])),
                            DataCell(Text(
                                _indexToLetter(question['correctAnswer'] ?? -1))), // Handle null correctAnswer
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}