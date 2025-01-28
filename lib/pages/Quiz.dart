import 'dart:convert';
import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html; // For web-specific code

class QuizComponent extends StatefulWidget {
  const QuizComponent({super.key});

  @override
  _QuizComponentState createState() => _QuizComponentState();
}

class _QuizComponentState extends State<QuizComponent> {
  final List<TextEditingController> questionControllers = [];
  final List<TextEditingController> categoryControllers = [];
  final List<Map<String, dynamic>> quizData = [];

  // Add a new question
  void addNewQuestion() {
    setState(() {
      quizData.add({
        'questionTitle': '',
        'questionImage': null, // Store question image
        'category': '',
        'choices': [],
        'correctAnswer': 0,
      });

      questionControllers.add(TextEditingController());
      categoryControllers.add(TextEditingController());
    });
  }

  // Pick image for a question or choice
  Future<void> pickImage({required int questionIndex, int? choiceIndex}) async {
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

          setState(() {
            if (choiceIndex == null) {
              // Set image for the question title
              quizData[questionIndex]['questionImage'] =
                  'data:${file.type};base64,$base64String';
            } else {
              // Set image for the choice
              quizData[questionIndex]['choices'][choiceIndex]['image'] =
                  'data:${file.type};base64,$base64String';
            }
          });
        });
      }
    });
  }

  // Save or submit quiz data
  void submitQuiz() async {
    // Perform submission logic, e.g., sending quizData to a server or saving locally
    final response = await Apiservice.createMultipleQuiz(quizData);
    Toast.show(context, message: response);
  }

  // Remove a question
  void removeQuestion(int questionIndex) {
    setState(() {
      quizData.removeAt(questionIndex);
      questionControllers.removeAt(questionIndex);
      categoryControllers.removeAt(questionIndex);
    });
  }

  // Remove image from the question title
  void removeQuestionImage(int questionIndex) {
    setState(() {
      quizData[questionIndex]['questionImage'] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: addNewQuestion,
            child: const Text("Add New Question"),
          ),
          for (int i = 0; i < quizData.length; i++) ...[
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: questionControllers[i],
                            decoration: const InputDecoration(
                              labelText: 'Question Title',
                            ),
                            onChanged: (value) {
                              quizData[i]['questionTitle'] = value;
                            },
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => pickImage(questionIndex: i)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeQuestion(i),
                        ),
                      ],
                    ),
                    if (quizData[i]['questionImage'] != null)
                      Stack(
                        children: [
                          Image.network(
                            quizData[i]['questionImage'],
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => removeQuestionImage(i),
                            ),
                          ),
                        ],
                      ),
                    TextField(
                      controller: categoryControllers[i],
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
                                pickImage(questionIndex: i, choiceIndex: j),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                quizData[i]['choices'].removeAt(j);
                                if (quizData[i]['correctAnswer'] >=
                                    quizData[i]['choices'].length) {
                                  quizData[i]['correctAnswer'] = 0;
                                }
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
                          quizData[i]['correctAnswer'] = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          ElevatedButton(
            onPressed: submitQuiz,
            child: const Text("Submit Quiz"),
          ),
        ],
      ),
    );
  }
}
