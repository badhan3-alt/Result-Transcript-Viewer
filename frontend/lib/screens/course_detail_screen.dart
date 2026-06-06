import 'package:flutter/material.dart';
import '../theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const CourseDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final courseName = result['course_name'] ?? 'Unknown Course';
    final courseCode = result['course_code'] ?? 'N/A';
    final credits = result['credit'] ?? 0;
    final grade = result['grade'] ?? 'N/A';
    final gradePoint = result['grade_point'] ?? 0.0;
    final semester = result['semester'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Analysis'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCourseHeader(courseName, courseCode),
            const SizedBox(height: 32),
            const Text(
              'PERFORMANCE METRICS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildDetailTile('Grade Achieved', grade, isBold: true, valueColor: _getGradeColor(grade)),
            _buildDetailTile('Weighted GPA', gradePoint.toStringAsFixed(2)),
            _buildDetailTile('Semester Block', 'Semester $semester'),
            const SizedBox(height: 32),
            const Text(
              'ENROLLMENT DATA',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildDetailTile('Reference Code', courseCode),
            _buildDetailTile('Credit Value', '$credits Credits'),
            _buildDetailTile('Instruction Level', 'Undergraduate'),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: BorderSide(color: AppTheme.navyColor.withOpacity(0.1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Dispute Record', style: TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(String name, String code) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.navyColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tealColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, size: 32, color: AppTheme.tealColor),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppTheme.navyColor,
            ),
          ),
        ],
      ),
    );
  }

  Color? _getGradeColor(String grade) {
    if (grade == 'F') return Colors.red;
    if (grade.startsWith('A')) return AppTheme.tealColor;
    return AppTheme.navyColor;
  }
}
