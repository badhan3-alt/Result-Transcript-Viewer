import 'package:flutter/material.dart';
import 'course_detail_screen.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
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
        title: const Text('Academic Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.navyColor));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading academic records'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No academic records found'));
          }

          final results = snapshot.data!;
          // Calculate Weighted CGPA
          double totalWeightedPoints = 0;
          double totalCredits = 0;
          for (var r in results) {
            double gp = r['grade_point'] ?? 0.0;
            double cr = (r['credit'] ?? 0).toDouble();
            totalWeightedPoints += (gp * cr);
            totalCredits += cr;
          }
          double cgpa = totalCredits > 0 ? totalWeightedPoints / totalCredits : 0.0;

          // Group by semester for "details"
          Map<int, List<dynamic>> grouped = {};
          for (var item in results) {
            int sem = item['semester'] ?? 0;
            grouped.putIfAbsent(sem, () => []).add(item);
          }
          var sortedSemesters = grouped.keys.toList()..sort();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildGPACard(cgpa, totalCredits)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Row(
                    children: [
                      Text(
                        'Result Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    int sem = sortedSemesters[index];
                    List<dynamic> semesterResults = grouped[sem]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                          child: Text(
                            'SEMESTER $sem',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppTheme.navyColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                        ...semesterResults.map((r) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildCourseCard(r),
                        )),
                      ],
                    );
                  },
                  childCount: sortedSemesters.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGPACard(double cgpa, double totalCredits) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navyColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'CUMULATIVE SEMESTER GPA',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cgpa.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 8),
                child: Text(
                  '/ 4.0',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.tealColor, size: 20),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dean\'s List Eligible', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Outstanding Achievement', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMiniStat(totalCredits.toStringAsFixed(0), 'CREDITS')),
              const SizedBox(width: 12),
              Expanded(child: _buildMiniStat('TOP 5%', 'COHORT')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(dynamic result) {
    final name = result['course_name'] ?? 'Unknown';
    final code = result['course_code'] ?? 'CS101';
    final grade = result['grade'] ?? 'N/A';
    final points = result['grade_point'] ?? 0.0;
    final credits = result['credit'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(result: result),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(code.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text(code.replaceAll(RegExp(r'[^0-9]'), ''), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyColor, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Theory • $credits Credits', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(grade, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.tealColor)),
                    Text('${points.toStringAsFixed(1)} PTS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
