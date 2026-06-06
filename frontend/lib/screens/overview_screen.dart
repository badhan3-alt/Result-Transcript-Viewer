import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Future<List<dynamic>> _offeredFuture;

  @override
  void initState() {
    super.initState();
    _offeredFuture = ApiService.fetchOfferedCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.navyColor),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _offeredFuture = ApiService.fetchOfferedCourses();
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeHeader()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Offered Courses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyColor,
                  ),
                ),
              ),
            ),
            _buildOfferedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.navyColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.tealColor,
                child: Text(
                  (ApiService.loggedInUsername ?? 'S').substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  Text(
                    ApiService.loggedInUsername ?? 'Student',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'You are currently in Semester ${ApiService.loggedInSemester ?? '?'}. Enrollment is open for your courses below.',
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferedList() {
    return FutureBuilder<List<dynamic>>(
      future: _offeredFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.navyColor)),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No courses offered for your batch yet')),
          );
        }

        final offered = snapshot.data!;
        Map<int, List<dynamic>> grouped = {};
        for (var item in offered) {
          int sem = item['semester'] ?? 0;
          grouped.putIfAbsent(sem, () => []).add(item);
        }
        var sortedSemesters = grouped.keys.toList()..sort();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                int sem = sortedSemesters[index];
                List<dynamic> courses = grouped[sem]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'SEMESTER $sem',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppTheme.navyColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    ...courses.map((c) => _buildOfferedCard(c)),
                  ],
                );
              },
              childCount: sortedSemesters.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferedCard(dynamic offeredCourse) {
    final course = offeredCourse['course_details'] ?? {};
    final name = course['course_name'] ?? 'Unknown';
    final code = course['course_code'] ?? 'N/A';
    final credits = course['credit'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              code.substring(0, 2).toUpperCase(),
              style: const TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyColor),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$code • $credits Credits', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.navyColor),
      ),
    );
  }
}
