import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use http://10.0.2.2:8000 for Android emulator, or http://127.0.0.1:8000 for iOS/Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000';
  }

  static int? loggedInStudentId;
  static String? loggedInEmail;
  static String? loggedInUsername;
  static String? loggedInStudentIdStr;
  static String? loggedInDepartment;
  static String? loggedInBatch;
  static int? loggedInSemester;
  static String? loggedInAcademicYear;
  static String? loggedInAdviser;
  static String? loggedInStatus;
  static String? loggedInUserType;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        body = {'error': 'Server returned an invalid response. Check your credentials.'};
      }
      if (response.statusCode == 200) {
        loggedInStudentId = body['student_id'];
        loggedInEmail = body['email'];
        loggedInUsername = body['username'];
        loggedInStudentIdStr = body['student_id_str'];
        loggedInDepartment = body['department'];
        loggedInBatch = body['batch'];
        loggedInSemester = body['current_semester'];
        loggedInAcademicYear = body['academic_year'];
        loggedInAdviser = body['faculty_adviser'];
        loggedInStatus = body['enrollment_status'];
        loggedInUserType = body['user_type'];
        
        await saveLoginData();
      }

      return {
        'status': response.statusCode,
        'body': body,
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<void> saveLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    if (loggedInEmail != null) await prefs.setString('email', loggedInEmail!);
    if (loggedInUsername != null) await prefs.setString('username', loggedInUsername!);
    if (loggedInStudentId != null) await prefs.setInt('student_id', loggedInStudentId!);
    if (loggedInStudentIdStr != null) await prefs.setString('student_id_str', loggedInStudentIdStr!);
    if (loggedInDepartment != null) await prefs.setString('department', loggedInDepartment!);
    if (loggedInBatch != null) await prefs.setString('batch', loggedInBatch!);
    if (loggedInSemester != null) await prefs.setInt('current_semester', loggedInSemester!);
    if (loggedInAcademicYear != null) await prefs.setString('academic_year', loggedInAcademicYear!);
    if (loggedInAdviser != null) await prefs.setString('faculty_adviser', loggedInAdviser!);
    if (loggedInStatus != null) await prefs.setString('enrollment_status', loggedInStatus!);
    if (loggedInUserType != null) await prefs.setString('user_type', loggedInUserType!);
  }

  static Future<bool> loadLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email') && prefs.containsKey('user_type')) {
      loggedInEmail = prefs.getString('email');
      loggedInUsername = prefs.getString('username');
      loggedInStudentId = prefs.getInt('student_id');
      loggedInStudentIdStr = prefs.getString('student_id_str');
      loggedInDepartment = prefs.getString('department');
      loggedInBatch = prefs.getString('batch');
      loggedInSemester = prefs.getInt('current_semester');
      loggedInAcademicYear = prefs.getString('academic_year');
      loggedInAdviser = prefs.getString('faculty_adviser');
      loggedInStatus = prefs.getString('enrollment_status');
      loggedInUserType = prefs.getString('user_type');
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    loggedInStudentId = null;
    loggedInEmail = null;
    loggedInUsername = null;
    loggedInStudentIdStr = null;
    loggedInDepartment = null;
    loggedInBatch = null;
    loggedInSemester = null;
    loggedInAcademicYear = null;
    loggedInAdviser = null;
    loggedInStatus = null;
    loggedInUserType = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String department,
    required String password,
    String? studentId,
    String? batch,
    String userType = 'student',
  }) async {
    final url = Uri.parse('$baseUrl/users/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'student_id': studentId,
          'department': department,
          'batch': batch,
          'password': password,
          'user_type': userType,
        }),
      );

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        body = {'error': 'Server error during registration. Check backend logs.'};
      }

      return {
        'status': response.statusCode,
        'body': body,
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/users/verify-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        body = {'error': 'Server error during OTP verification.'};
      }

      if (response.statusCode == 200) {
        loggedInStudentId = body['student_id'];
        loggedInEmail = body['email'];
        loggedInUsername = body['username'];
        loggedInStudentIdStr = body['student_id_str'];
        loggedInDepartment = body['department'];
        loggedInBatch = body['batch'];
        loggedInSemester = body['current_semester'];
        loggedInAcademicYear = body['academic_year'];
        loggedInAdviser = body['faculty_adviser'];
        loggedInStatus = body['enrollment_status'];
        loggedInUserType = body['user_type'];
        
        await saveLoginData();
      }

      return {
        'status': response.statusCode,
        'body': body,
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<List<dynamic>> fetchAllStudents({String? department}) async {
    String urlStr = '$baseUrl/users/students/';
    if (department != null) {
      urlStr += '?department=$department';
    }
    final url = Uri.parse(urlStr);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> updateStudentProfile({
    required int id,
    int? semester,
    String? status,
    String? academicYear,
  }) async {
    final url = Uri.parse('$baseUrl/users/students/$id/update/');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (semester != null) 'current_semester': semester,
          if (status != null) 'enrollment_status': status,
          if (academicYear != null) 'academic_year': academicYear,
        }),
      );

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<List<dynamic>> fetchAllCourses() async {
    final url = Uri.parse('$baseUrl/courses/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching courses: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> submitOfferedCourse({
    required int courseId,
    required String department,
    required String batch,
    required int semester,
  }) async {
    final url = Uri.parse('$baseUrl/courses/offered/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course': courseId,
          'department': department,
          'batch': batch,
          'semester': semester,
        }),
      );

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> submitResult({
    required int studentId,
    required int courseId,
    required String grade,
    required int semester,
  }) async {
    final url = Uri.parse('$baseUrl/results/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student': studentId,
          'course': courseId,
          'grade': grade,
          'semester': semester,
        }),
      );

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }

  static Future<List<dynamic>> fetchResults({int? semester}) async {
    if(loggedInStudentIdStr == null) return [];
    
    String urlStr = '$baseUrl/results/student/$loggedInStudentIdStr/';
    if (semester != null) {
      urlStr += '?semester=$semester';
    }
    
    final url = Uri.parse(urlStr);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching results: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> fetchTranscript(int studentId) async {
    final url = Uri.parse('$baseUrl/transcripts/$studentId/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching transcript: $e');
    }
    return {};
  }

  static Future<List<dynamic>> fetchOfferedCourses({int? semester}) async {
    if (loggedInStudentIdStr == null) return [];

    String urlStr = '$baseUrl/courses/offered/?student_id=$loggedInStudentIdStr';
    if (semester != null) {
      urlStr += '&semester=$semester';
    }

    final url = Uri.parse(urlStr);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching offered courses: $e');
    }
    return [];
  }

  static Future<List<dynamic>> fetchTransactions() async {
    if (loggedInStudentIdStr == null) return [];

    final url = Uri.parse('$baseUrl/payments/student-transactions/?student_id=$loggedInStudentIdStr');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> requestPaymentOtp(String email) async {
    final url = Uri.parse('$baseUrl/payments/request-otp/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {'status': 500, 'body': {'error': e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> submitTransaction({
    required String title,
    required double amount,
    required String method,
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/payments/submit/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'method': method,
          'student_id_str': loggedInStudentIdStr,
          'email': email,
          'otp': otp,
        }),
      );

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'error': e.toString()},
      };
    }
  }
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/users/forgot-password/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {'status': 500, 'body': {'error': e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final url = Uri.parse('$baseUrl/users/reset-password/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {'status': 500, 'body': {'error': e.toString()}};
    }
  }
}
