import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class StudentAdvisingScreen extends StatefulWidget {
  const StudentAdvisingScreen({super.key});

  @override
  State<StudentAdvisingScreen> createState() => _StudentAdvisingScreenState();
}

class _StudentAdvisingScreenState extends State<StudentAdvisingScreen> {
  late Future<List<dynamic>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = ApiService.fetchAllStudents(department: ApiService.loggedInDepartment);
  }

  void _showEditDialog(dynamic student) {
    final semesterController = TextEditingController(text: student['current_semester']?.toString() ?? '1');
    final yearController = TextEditingController(text: student['academic_year'] ?? '2023-2024');
    String status = student['enrollment_status'] ?? 'Regular';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Advise ${student['username']}', style: const TextStyle(color: AppTheme.navyColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: semesterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Semester'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Academic Year'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ['Regular', 'Irregular', 'Probation', 'Withdrawn'].map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) => setDialogState(() => status = val!),
                  decoration: const InputDecoration(labelText: 'Enrollment Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final response = await ApiService.updateStudentProfile(
                  id: student['id'],
                  semester: int.tryParse(semesterController.text),
                  academicYear: yearController.text,
                  status: status,
                );
                if (response['status'] == 200) {
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {
                      _studentsFuture = ApiService.fetchAllStudents(department: ApiService.loggedInDepartment);
                    });
                  }
                }
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Student Advising')),
      body: FutureBuilder<List<dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students in your department yet.'));
          }

          final students = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.bgColor,
                    child: Text(student['username'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
                  ),
                  title: Text(student['username'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Batch: ${student['batch'] ?? 'N/A'} • Sem: ${student['current_semester']}'),
                      Text('Status: ${student['enrollment_status']}', style: TextStyle(color: _getStatusColor(student['enrollment_status']), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.navyColor),
                    onPressed: () => _showEditDialog(student),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'regular': return Colors.teal;
      case 'probation': return Colors.orange;
      case 'withdrawn': return Colors.red;
      default: return Colors.grey;
    }
  }
}
