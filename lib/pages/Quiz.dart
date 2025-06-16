import 'dart:convert';
import 'package:admission/components/Toast.dart';
import 'package:admission/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For cross-platform file selection

class QuizComponent extends StatefulWidget {
  const QuizComponent({super.key});

  @override
  _QuizComponentState createState() => _QuizComponentState();
}

class _QuizComponentState extends State<QuizComponent> {
  final List<TextEditingController> questionControllers = [];
  final List<TextEditingController> categoryControllers = [];
  final List<Map<String, dynamic>> quizData = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one question when the component starts
    addNewQuestion();
  }

  @override
  void dispose() {
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in categoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Add a new question
  void addNewQuestion() {
    setState(() {
      quizData.add({
        'questionTitle': '',
        'questionImage': null, // Store question image
        'category': '',
        'choices': [],
        'correctAnswer': null,
      });

      questionControllers.add(TextEditingController());
      categoryControllers.add(TextEditingController());
    });
  }

  // Pick an image for a question or choice
  Future<void> pickImage({required int questionIndex, int? choiceIndex}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final base64String = base64Encode(fileBytes); // Convert to Base64
      final fileExtension = result.files.single.extension;
      final mimeType = _getMimeType(fileExtension); // Determine MIME type

      setState(() {
        if (choiceIndex == null) {
          quizData[questionIndex]['questionImage'] =
              'data:$mimeType;base64,$base64String';
        } else {
          quizData[questionIndex]['choices'][choiceIndex]['image'] =
              'data:$mimeType;base64,$base64String';
        }
      });
    } else {
      // User canceled the picker or no file selected
      Toast.show(context, message: "No image selected.");
    }
  }

  // Helper to determine MIME type based on file extension
  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream'; // Fallback
    }
  }

  // Check if all fields are filled
  bool isFormComplete() {
    if (quizData.isEmpty) return false;

    for (var question in quizData) {
      if (question['questionTitle'].trim().isEmpty ||
          question['category'].trim().isEmpty ||
          question['choices'].isEmpty ||
          question['correctAnswer'] == null) {
        return false;
      }
      for (var choice in question['choices']) {
        if (choice['text'].trim().isEmpty) return false;
      }
    }
    return true;
  }

  // Remove a question
  void removeQuestion(int questionIndex) {
    setState(() {
      questionControllers[questionIndex].dispose(); // Dispose controller
      categoryControllers[questionIndex].dispose(); // Dispose controller
      quizData.removeAt(questionIndex);
      questionControllers.removeAt(questionIndex);
      categoryControllers.removeAt(questionIndex);
    });
  }

  // Remove image from a question
  void removeQuestionImage(int questionIndex) {
    setState(() {
      quizData[questionIndex]['questionImage'] = null;
    });
  }

  // Remove image from a choice
  void removeChoiceImage(int questionIndex, int choiceIndex) {
    setState(() {
      quizData[questionIndex]['choices'][choiceIndex]['image'] = null;
    });
  }

  // Submit quiz data
  void submitQuiz() async {
    if (!isFormComplete()) {
      return Toast.show(context, message: "Please fill in all fields.");
    }

    // You might want to show a loading indicator here
    Toast.show(context, message: "Submitting quiz...");

    final response = await Apiservice.createMultipleQuiz(quizData);
    Toast.show(context, message: response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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
                                    labelText: 'Question Title'),
                                onChanged: (value) {
                                  setState(() {
                                    quizData[i]['questionTitle'] = value;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                                icon:
                                    const Icon(Icons.image, color: Colors.blue),
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
                              Image.memory(
                                base64Decode(
                                    quizData[i]['questionImage'].split(',')[1]),
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () => removeQuestionImage(i),
                                ),
                              ),
                            ],
                          ),
                        TextField(
                          controller: categoryControllers[i],
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                          onChanged: (value) {
                            setState(() {
                              quizData[i]['category'] = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        for (int j = 0;
                            j < quizData[i]['choices'].length;
                            j++) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Choice'),
                                  onChanged: (value) {
                                    setState(() {
                                      quizData[i]['choices'][j]['text'] = value;
                                    });
                                  },
                                  // You might want to add a TextEditingController for choices as well
                                ),
                              ),
                              if (quizData[i]['choices'][j]['image'] != null)
                                Stack(
                                  children: [
                                    Image.memory(
                                      base64Decode(quizData[i]['choices'][j]
                                              ['image']
                                          .split(',')[1]),
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () =>
                                            removeChoiceImage(i, j),
                                      ),
                                    ),
                                  ],
                                ),
                              IconButton(
                                icon:
                                    const Icon(Icons.image, color: Colors.blue),
                                onPressed: () =>
                                    pickImage(questionIndex: i, choiceIndex: j),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    quizData[i]['choices'].removeAt(j);
                                    // If the removed choice was the correct answer, reset correctAnswer
                                    if (quizData[i]['correctAnswer'] == j) {
                                      quizData[i]['correctAnswer'] = null;
                                    } else if (quizData[i]['correctAnswer'] !=
                                            null &&
                                        quizData[i]['correctAnswer']! > j) {
                                      // Adjust correct answer index if it's after the removed choice
                                      quizData[i]['correctAnswer'] =
                                          quizData[i]['correctAnswer']! - 1;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              quizData[i]['choices']
                                  .add({'text': '', 'image': null});
                            });
                          },
                          child: const Text("Add Choice"),
                        ),
                        if (quizData[i]['choices'].isNotEmpty)
                          DropdownButton<int>(
                            value: quizData[i]['correctAnswer'],
                            hint: const Text("Select Correct Answer"),
                            items: List.generate(
                              quizData[i]['choices'].length,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text(
                                    'Choice ${index + 1}: ${quizData[i]['choices'][index]['text']}'), // Show choice text
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: submitQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormComplete()
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Submit Quiz"),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }
}
