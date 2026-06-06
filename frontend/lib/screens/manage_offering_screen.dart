import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ManageOfferingScreen extends StatefulWidget {
  const ManageOfferingScreen({super.key});

  @override
  State<ManageOfferingScreen> createState() => _ManageOfferingScreenState();
}

class _ManageOfferingScreenState extends State<ManageOfferingScreen> {
  final _batchController = TextEditingController();
  final _semesterController = TextEditingController();
  
  List<dynamic> _courses = [];
  String? _selectedCourseId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courses = await ApiService.fetchAllCourses();
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedCourseId == null || _batchController.text.isEmpty || _semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await ApiService.submitOfferedCourse(
      courseId: int.parse(_selectedCourseId!),
      department: ApiService.loggedInDepartment!,
      batch: _batchController.text.trim(),
      semester: int.parse(_semesterController.text),
    );

    setState(() => _isSubmitting = false);

    if (response['status'] == 201 || response['status'] == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course offered successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to offer course.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Manage Offerings')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Offer New Course',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assign a course to a specific batch in your department.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel('Target Department'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.bgColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(ApiService.loggedInDepartment ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Select Course'),
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    items: _courses.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'].toString(),
                        child: Text(c['course_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                    decoration: const InputDecoration(hintText: 'Choose from catalogue'),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Target Batch (e.g., Spring-24)'),
                  TextField(
                    controller: _batchController,
                    decoration: const InputDecoration(hintText: 'Enter batch code'),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Target Semester'),
                  TextField(
                    controller: _semesterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Enter semester number'),
                  ),
                  
                  const SizedBox(height: 48),
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Active Course Offering', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
    );
  }
}
