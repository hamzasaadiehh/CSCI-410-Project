import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_project/filter_grades_page.dart';
import 'package:mobile_project/students.dart';

void main() {
  runApp(const StudentGradesApp());
}

class StudentGradesApp extends StatelessWidget {
  const StudentGradesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grades',
      home: const StudentsListPage(),
    );
  }
}

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<Student> students = [];

  Future<void> loadStudents() async {
    try {
      final url = Uri.http("localhost", "/project-mobile/getStudents.php");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        setState(() {
          students = jsonResponse.map<Student>((row) {
            return Student(
              id: int.parse(row['db_id']),
              name: row['db_name'],
              grade: int.parse(row['db_grade']),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error: $e');
      // Optionally, show an error message to the user.
    }
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grades'),
        centerTitle: true,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: students.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Grade: ${student.grade}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => FilterGradesPage(students: students),
                ),
              );
      },
      child: const Icon(Icons.filter_alt_outlined),),

    );
  }
}
