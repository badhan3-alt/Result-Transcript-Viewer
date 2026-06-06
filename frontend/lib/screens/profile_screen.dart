import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.navyColor,
              child: Icon(Icons.person, size: 60, color: AppTheme.tealColor),
            ),
            const SizedBox(height: 20),
            Text(
              ApiService.loggedInUsername ?? 'Student Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.tealColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (ApiService.loggedInStatus ?? 'REGULAR').toUpperCase(),
                style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionHeader('ACADEMIC INFORMATION'),
            _buildProfileItem(Icons.school_outlined, 'Current Semester', 'Semester ${ApiService.loggedInSemester?.toString().padLeft(2, '0') ?? 'N/A'}'),
            _buildProfileItem(Icons.calendar_today_outlined, 'Academic Year', ApiService.loggedInAcademicYear ?? 'N/A'),
            _buildProfileItem(Icons.business_outlined, 'Department', ApiService.loggedInDepartment ?? 'N/A'),
            _buildProfileItem(Icons.group_outlined, 'Batch / Cohort', ApiService.loggedInBatch ?? 'N/A'),
            
            const SizedBox(height: 24),
            _buildSectionHeader('PERSONAL IDENTITY'),
            _buildProfileItem(Icons.badge_outlined, 'Student System ID', ApiService.loggedInStudentIdStr ?? 'N/A'),
            _buildProfileItem(Icons.email_outlined, 'Institutional Email', ApiService.loggedInEmail ?? 'N/A'),
            _buildProfileItem(Icons.person_pin_outlined, 'Faculty Adviser', ApiService.loggedInAdviser ?? 'N/A'),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                await ApiService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Secure Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.navyColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyColor, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
