import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLoginPressed() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(AuthLoginRequested(username, password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a background color from your color scheme if desired
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Navigate to timesheet screen on success
              Navigator.pushReplacementNamed(context, '/timesheet');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120, // adjust size as desired
                    ),
                    const SizedBox(height: 24), // Add spacing here
                    // App logo or title
                    // Text(
                    //   'Bus Tecnología',
                    //   style:
                    //       Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    // ),
                    // const SizedBox(height: 24),
                    // Card with login fields
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const CircularProgressIndicator();
                                } else if (state is AuthFailure) {
                                  // Show error message
                                  return Column(
                                    children: [
                                      Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _onLoginPressed,
                                        child: const Text('Try Again'),
                                      ),
                                    ],
                                  );
                                }
                                // Default: show login button
                                return ElevatedButton(
                                  onPressed: _onLoginPressed,
                                  child: const Text('Login'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
