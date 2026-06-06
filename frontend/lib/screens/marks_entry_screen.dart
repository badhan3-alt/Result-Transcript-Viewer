import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final _semesterController = TextEditingController();
  
  List<dynamic> _students = [];
  List<dynamic> _courses = [];
  
  String? _selectedStudentId;
  String? _selectedCourseId;
  String? _selectedGrade;
  
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final List<String> _grades = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "D", "F"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    
    // Fetch students in the teacher's specific department
    final students = await ApiService.fetchAllStudents(department: ApiService.loggedInDepartment);
    final courses = await ApiService.fetchAllCourses();
    
    setState(() {
      _students = students;
      _courses = courses;
      _isLoadingData = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedStudentId == null || _selectedCourseId == null || _selectedGrade == null || _semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select student, course, grade, and semester'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await ApiService.submitResult(
      studentId: int.parse(_selectedStudentId!),
      courseId: int.parse(_selectedCourseId!),
      grade: _selectedGrade!,
      semester: int.parse(_semesterController.text),
    );

    setState(() => _isSubmitting = false);

    if (response['status'] == 201 || response['status'] == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit marks. Please try again.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Marks Entry Portal'),
      ),
      body: _isLoadingData 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.navyColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  
                  _buildDropdownSection(
                    label: 'Academic Semester',
                    icon: Icons.calendar_month_rounded,
                    child: TextField(
                      controller: _semesterController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Semester (e.g., 4)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownSection(
                    label: 'Select Course',
                    icon: Icons.book_outlined,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCourseId,
                        hint: const Text('Choose Course'),
                        isExpanded: true,
                        items: _courses.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['id'].toString(),
                            child: Text('${c['course_code']} - ${c['course_name']}'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCourseId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownSection(
                    label: 'Select Student (${ApiService.loggedInDepartment})',
                    icon: Icons.person_search_outlined,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStudentId,
                        hint: Text(_students.isEmpty ? 'No students found in ${ApiService.loggedInDepartment}' : 'Choose Student'),
                        isExpanded: true,
                        items: _students.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['id'].toString(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s['username'].toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  "ID: ${s['student_id']}", 
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return _students.map((s) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${s['username']} [ID: ${s['student_id']}]",
                                style: const TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (val) => setState(() => _selectedStudentId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownSection(
                    label: 'Assigned Grade',
                    icon: Icons.grade_outlined,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGrade,
                        hint: const Text('Choose Grade'),
                        isExpanded: true,
                        items: _grades.map((g) {
                          return DropdownMenuItem<String>(
                            value: g,
                            child: Text(g, style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedGrade = val),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.navyColor))
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          child: const Text('Submit Academic Marks', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Academic Performance',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Submit official results for students in the ${ApiService.loggedInDepartment ?? 'your'} department.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDropdownSection({required String label, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.navyColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}
