import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:html' as html; // For web-specific code

class QuizComponent extends StatefulWidget {
  const QuizComponent({super.key});

  @override
  _QuizComponentState createState() => _QuizComponentState();
}

class _QuizComponentState extends State<QuizComponent> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final List<Map<String, dynamic>> quizData = [];

  // Add a new question
  void addNewQuestion() {
    setState(() {
      quizData.add({
        'questionTitle': '',
        'category': '',
        'choices': [],
        'correctAnswer': 0,
      });
    });
  }

  // Pick image for a choice
  Future<void> pickImage(int questionIndex, int choiceIndex) async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files?.isEmpty ?? true) return;
      final file = files?.first;

      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file); // Read file as bytes
        reader.onLoadEnd.listen((event) {
          final fileBytes = reader.result as List<int>;
          final base64String = base64Encode(fileBytes); // Convert to Base64

          // Set the Base64 string to your quiz data
          setState(() {
            quizData[questionIndex]['choices'][choiceIndex]['image'] =
                'data:${file.type};base64,$base64String'; // Include MIME type
          });
        });
      }
    });
  }

  // Save or submit quiz data
  void submitQuiz() {
    // Perform submission logic, e.g., sending quizData to a server or saving locally
    var result = jsonEncode(quizData);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: addNewQuestion,
          child: const Text("Add New Question"),
        ),
        for (int i = 0; i < quizData.length; i++) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: questionController,
                  decoration:
                      const InputDecoration(labelText: 'Question Title'),
                  onChanged: (value) {
                    quizData[i]['questionTitle'] = value;
                  },
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: (value) {
                    quizData[i]['category'] = value;
                  },
                ),
                const SizedBox(height: 10),
                for (int j = 0; j < quizData[i]['choices'].length; j++) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Choice ${j + 1}',
                            hintText: 'Enter choice ${j + 1}',
                          ),
                          onChanged: (value) {
                            quizData[i]['choices'][j]['text'] = value;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () =>
                            pickImage(i, j), // Pick image for this choice
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            print(
                                'current Correct Answer: ${quizData[i]['correctAnswer']}');
                            print(
                                'before remove quiz choices length : ${quizData[i]['choices'].length}');

                            if (quizData[i]['choices'].isNotEmpty) {
                              quizData[i]['choices'].removeAt(
                                  i); // Replace indexToRemove with the index of the choice you want to delete
                            }
                            if (quizData[i]['correctAnswer'] ==
                                quizData[i]['choices'].length) {
                              setState(() {
                                quizData[i]['correctAnswer'] = 0;
                              });
                            }
                            print(
                                'after remove quiz correct Answer index : ${quizData[i]['correctAnswer']}');
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      quizData[i]['choices'].add({
                        'text': '',
                        'image': null,
                      });
                    });
                  },
                  child: const Text("Add Choice"),
                ),
                const SizedBox(height: 10),
                DropdownButton<int>(
                  value: quizData[i]['correctAnswer'],
                  items: List.generate(
                    quizData[i]['choices'].length,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text('Choice ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      print('value correct Answer here $value');
                      quizData[i]['correctAnswer'] = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        ElevatedButton(
          onPressed: submitQuiz,
          child: const Text("Submit Quiz"),
        ),
      ],
    );
  }
}
