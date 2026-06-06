import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'otp_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _batchController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _userType = 'student'; // 'student' or 'teacher'
  bool _isLoading = false;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final studentId = _studentIdController.text.trim();
    final department = _departmentController.text.trim();
    final batch = _batchController.text.trim();
    final password = _passwordController.text;

    // Validation logic based on role
    bool isStudent = _userType == 'student';
    if (username.isEmpty || email.isEmpty || department.isEmpty || password.isEmpty || 
        (isStudent && (studentId.isEmpty || batch.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (password.length <= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must have more than 8 characters'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.register(
      username: username,
      email: email,
      studentId: isStudent ? studentId : null,
      department: department,
      batch: isStudent ? batch : null,
      password: password,
      userType: _userType,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 201) {
      if (mounted) {
        final body = response['body'];
        String returnedEmail = body['email'] ?? email;
        bool emailSent = body['email_sent'] ?? true;
        String? terminalOtp = body['otp_in_terminal'];

        if (!emailSent && terminalOtp != null) {
          // Show a dialog with the OTP since real email failed
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Email Service Offline'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Real email delivery failed. Since you are in development, please use this OTP to verify:'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      terminalOtp,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppTheme.navyColor),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OTPVerificationScreen(email: returnedEmail)),
                    );
                  },
                  child: const Text('PROCEED TO VERIFY'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration initiated! Please check your email for OTP.'), backgroundColor: Colors.blue),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OTPVerificationScreen(email: returnedEmail)),
          );
        }
      }
    } else {
      dynamic errorBody = response['body'];
      String errorMessage = 'Registration failed. Please try again.';
      
      if (errorBody is Map) {
        if (errorBody.containsKey('error')) {
          errorMessage = errorBody['error'].toString();
        } else {
          errorMessage = errorBody.entries.map((e) => '${e.key}: ${(e.value is List) ? e.value.join(', ') : e.value}').join('\n');
        }
      } else {
        errorMessage = errorBody.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 4)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isStudent = _userType == 'student';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Join the Ledger',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your role and enter institutional details.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Role Selector
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildRoleTab('student', 'STUDENT', Icons.school_outlined),
                  _buildRoleTab('teacher', 'TEACHER', Icons.person_pin_outlined),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildField(_usernameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_emailController, 'Institutional Email', Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField(
              _departmentController, 
              'Department', 
              Icons.business_outlined,
              readOnly: true,
              onTap: _showDepartmentDrawer,
            ),
            const SizedBox(height: 16),
            
            if (isStudent) ...[
              _buildField(_studentIdController, 'Student ID', Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildField(
                _batchController, 
                'Batch Code', 
                Icons.group_outlined,
                readOnly: true,
                onTap: _showBatchDrawer,
              ),
              const SizedBox(height: 16),
            ],
            
            _buildField(_passwordController, 'Security Password', Icons.lock_outline, isPassword: true),
            
            const SizedBox(height: 48),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.navyColor))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab(String type, String label, IconData icon) {
    bool isSelected = _userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppTheme.navyColor : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.navyColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text, bool isPassword = false, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.navyColor),
        suffixIcon: readOnly ? Icon(Icons.arrow_drop_down, color: AppTheme.navyColor) : null,
      ),
    );
  }

  void _showDepartmentDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Department',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: ['CSE', 'LAW', 'Eng', 'BBA'].map((dept) {
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: AppTheme.bgColor,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: ListTile(
                          leading: const Icon(Icons.business_outlined, color: AppTheme.navyColor),
                          title: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            setState(() {
                              _departmentController.text = dept;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _buildKiteDivider(),
            ],
          ),
        );
      },
    );
  }
  void _showBatchDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Batch',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(8, (index) => (index + 1).toString()).map((batch) {
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: AppTheme.bgColor,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        child: ListTile(
                          leading: const Icon(Icons.group_outlined, color: AppTheme.navyColor),
                          title: Text('Batch $batch', style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            setState(() {
                              _batchController.text = batch;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _buildKiteDivider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKiteDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '◢◤' * 20,
        style: TextStyle(
          color: AppTheme.navyColor.withOpacity(0.1),
          fontSize: 10,
          letterSpacing: 0,
        ),
        overflow: TextOverflow.clip,
        maxLines: 1,
      ),
    );
  }
}
