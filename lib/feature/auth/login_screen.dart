import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proplus/core/theme/theme_provider.dart';
import 'package:proplus/feature/auth/provider/login_provider.dart';
import 'package:proplus/feature/auth/state/login_state.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form validation methods
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    return null; // No error
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null; // No error
  }

  bool _isFormValid(String email, String password) {
    return _validateEmail(email) == null && _validatePassword(password) == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for error or success
    ref.listen<LoginState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (next.user != null) {
        // Navigate after successful login
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            SwitchListTile(
              title: const Text('Dark Mode'),
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
            // Email TextField
            TextField(
              controller: _emailController,
              enabled: !authState.isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _validateEmail(_emailController.text),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (_) {
                // Trigger rebuild to update validation
                (context as Element).markNeedsBuild();
              },
            ),
            const SizedBox(height: 20),

            // Password TextField
            TextField(
              controller: _passwordController,
              enabled: !authState.isLoading,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _validatePassword(_passwordController.text),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (_) {
                // Trigger rebuild to update validation
                (context as Element).markNeedsBuild();
              },
            ),
            const SizedBox(height: 10),

          DropdownButton<String>(
            value: ref.watch(selectedCountryProvider),
            items: const [
              DropdownMenuItem(
                value: 'Bangladesh',
                child: Text('Bangladesh'),
              ),
              DropdownMenuItem(
                value: 'India',
                child: Text('India'),
              ),
              DropdownMenuItem(
                value: 'USA',
                child: Text('USA'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedCountryProvider.notifier).state = value;
              }
            },
          ),

            Row(
              children: [
                Checkbox(
                  value: ref.watch(rememberMeProvider),
                  onChanged: (value) {
                    ref.read(rememberMeProvider.notifier).state = value ?? false;
                  },
                ),
                Text("Remember Me"),
              ],
            ),

            const SizedBox(height: 10),

            // Login Button
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      // Check if form is valid
                      if (!_isFormValid(email, password)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fix the errors in the form'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Make API call
                      ref.read(authProvider.notifier).login(email, password);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
