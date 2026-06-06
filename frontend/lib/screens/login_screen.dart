import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'registration_screen.dart';
import 'dashboard_screen.dart';
import 'teacher_dashboard.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password'), backgroundColor: Colors.redAccent),
      );
      return;
    }

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

    final response = await ApiService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 200) {
      if (mounted) {
        // Route based on User Type
        final userType = ApiService.loggedInUserType;
        
        if (userType == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } else {
      dynamic errorBody = response['body'];
      String errorMessage = 'Login failed. Please check your credentials.';
      
      if (errorBody is Map && errorBody.containsKey('error')) {
        errorMessage = errorBody['error'];
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password', style: TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your institutional email to receive a password reset OTP.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _handleForgotPassword(emailController.text.trim()),
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword(String email) async {
    if (email.isEmpty) return;
    
    Navigator.pop(context); // Close email dialog
    
    setState(() => _isLoading = true);
    final response = await ApiService.forgotPassword(email);
    setState(() => _isLoading = false);

    if (response['status'] == 200) {
      if (mounted) {
        _showResetPasswordDialog(email);
      }
    } else {
      String error = response['body']?['error'] ?? 'Failed to send OTP';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showResetPasswordDialog(String email) {
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isResetting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reset Password', style: TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the OTP sent to $email and your new password.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: '6-Digit OTP', prefixIcon: Icon(Icons.pin_outlined)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: isResetting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isResetting ? null : () async {
                final otp = otpController.text.trim();
                final pass = newPasswordController.text;
                
                if (otp.isEmpty || pass.isEmpty) return;

                setDialogState(() => isResetting = true);
                final res = await ApiService.resetPassword(email, otp, pass);
                setDialogState(() => isResetting = false);

                if (res['status'] == 200) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset successful! Please login.'), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  String error = res['body']?['error'] ?? 'Reset failed';
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              child: isResetting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Reset Password'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school_rounded, size: 80, color: AppTheme.navyColor),
              const SizedBox(height: 24),
              const Text(
                'The Academic Ledger',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.navyColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Institutional Access Portal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], letterSpacing: 1),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Institutional Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.navyColor),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Secure Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.navyColor),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.navyColor))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppTheme.navyColor, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'New to the institution? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    children: const [
                      TextSpan(
                        text: 'Create Account',
                        style: TextStyle(color: AppTheme.navyColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
