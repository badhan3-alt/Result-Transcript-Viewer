import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  late Future<List<dynamic>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = ApiService.fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Transcript'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined), 
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparing sharing options...'), duration: Duration(seconds: 1)),
              );
            }
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.navyColor));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transcript data available'));
          }

          final results = snapshot.data!;
          
          // Calculate Weighted CGPA & Total Credits
          double totalWeightedPoints = 0;
          double totalCredits = 0;
          for (var r in results) {
            double gp = r['grade_point'] ?? 0.0;
            double cr = (r['credit'] ?? 0).toDouble();
            totalWeightedPoints += (gp * cr);
            totalCredits += cr;
          }
          double cgpa = totalCredits > 0 ? totalWeightedPoints / totalCredits : 0.0;

          // Group by Year/Semester
          Map<String, List<dynamic>> groupedBySem = {};
          for (var r in results) {
            String semStr = 'Semester ${r['semester']}';
            groupedBySem.putIfAbsent(semStr, () => []).add(r);
          }
          var sortedSemesters = groupedBySem.keys.toList()..sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildTranscriptHeader(),
                const SizedBox(height: 32),
                _buildStudentIdentity(cgpa, totalCredits),
                const SizedBox(height: 48),
                ...sortedSemesters.map((sem) => _buildSemesterBlock(sem, groupedBySem[sem]!)),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Generating PDF Transcript...'),
              backgroundColor: AppTheme.navyColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: AppTheme.navyColor,
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('Export PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTranscriptHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.navyColor, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.school, color: AppTheme.tealColor, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Official Academic Transcript',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
        ),
        const Text(
          'Comprehensive record of credentials and institutional standing.',
          style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildStudentIdentity(double cgpa, double totalCredits) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STUDENT IDENTITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(ApiService.loggedInUsername ?? 'Student Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
          Text('ID: ${ApiService.loggedInStudentIdStr ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(height: 32),
          Row(
            children: [
              _IdentityStat(label: 'CUMULATIVE GPA', value: '${cgpa.toStringAsFixed(2)} / 4.0'),
              const SizedBox(width: 48),
              _IdentityStat(label: 'TOTAL CREDITS', value: totalCredits.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterBlock(String title, List<dynamic> semesterResults) {
    // Calculate semester weighted GPA
    double points = 0;
    double credits = 0;
    for (var r in semesterResults) {
      double gp = r['grade_point'] ?? 0.0;
      double cr = (r['credit'] ?? 0).toDouble();
      points += (gp * cr);
      credits += cr;
    }
    double semGpa = credits > 0 ? points / credits : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'GPA: ${semGpa.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(1.2),
          },
          children: [
            const TableRow(
              children: [
                _TableHead('CODE'),
                _TableHead('COURSE TITLE'),
                _TableHead('GRADE'),
              ],
            ),
            ...semesterResults.map((r) => TableRow(
              children: [
                _TableCell(r['course_code'] ?? 'N/A'),
                _TableCell(r['course_name'] ?? 'N/A'),
                _TableCell(r['grade'] ?? 'N/A', isBold: true),
              ],
            )),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String label;
  final String value;
  const _IdentityStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
      ],
    );
  }
}

class _TableHead extends StatelessWidget {
  final String text;
  const _TableHead(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  const _TableCell(this.text, {this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppTheme.navyColor,
        ),
      ),
    );
  }
}
