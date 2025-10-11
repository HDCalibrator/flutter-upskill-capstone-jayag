import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For FirebaseAuthException
import 'package:dryv_app/providers/auth_provider.dart'; // Adjust package name
import 'package:dryv_app/main.dart'; // Import for HomePage navigation
import 'dart:developer' as developer; // For logging

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true; // State for password visibility toggle

  Future<void> _signIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuthException: ${e.code} - ${e.message}',
      ); // Debug log
      setState(() {
        _errorMessage = _mapAuthErrorToMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      developer.log('General Exception: $e'); // Debug log
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .registerWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuthException: ${e.code} - ${e.message}',
      ); // Debug log
      setState(() {
        _errorMessage = _mapAuthErrorToMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      developer.log('General Exception: $e'); // Debug log
      setState(() {
        _errorMessage = 'An unexpected error occurred during registration.';
        _isLoading = false;
      });
    }
  }

  String _mapAuthErrorToMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
        return 'Wrong Password';
      case 'user-not-found':
        return 'Wrong Email';
      case 'invalid-email':
        return 'Wrong Email Format';
      case 'email-already-in-use':
        return 'Email Already Registered';
      case 'weak-password':
        return 'Weak Password';
      case 'too-many-requests':
        return 'Too Many Attempts';
      case 'network-request-failed':
        return 'Network Error';
      case 'invalid-credential':
        return 'Wrong Credentials';
      default:
        return 'Login Failed';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate to HomePage if authenticated
    if (authState.value != null && authState.value!.email != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AuthWrapper(child: HomePage()),
            ),
          );
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading during navigation
    }

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: SingleChildScrollView(
          // Ensure no overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            width: double.infinity, // Ensure it spans the width
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(
                                255,
                                0,
                                0,
                                0.1,
                              ), // Red with 10% opacity
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.white70),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : () => _signIn(),
                        child: const Text('Login to DryV'),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () => _register(),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
