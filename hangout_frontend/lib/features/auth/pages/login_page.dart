import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/auth/pages/signup_page.dart';
import 'package:hangout_frontend/features/home/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void loginUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          } else if (state is AuthLoggedIn) {
            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          return Container(
            //!!!!!!!!! MediaQuery
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[400]!,
                  Colors.green[400]!,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // const SizedBox(height: 40),
                        // Back Button
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.arrow_back,
                        //         color: Colors.white),
                        //     onPressed: () => Navigator.pop(context),
                        //   ),
                        // ),
                        const SizedBox(height: 60),
                        // // Welcome Text
                        // const Text(
                        //   'Welcome',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        Text(
                          'Afterwork',
                          style: TextStyle(
                            fontSize: 65,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Lifestyle Planner  ',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Easy-Plan, Easy-Life',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        // const SizedBox(height: 40),
                        // Logo Container
                        // Container(
                        //   height: 120,
                        //   width: 120,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: const Center(
                        //     child: Icon(
                        //       Icons.favorite,
                        //       size: 60,
                        //       color: Colors.blue,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        // Sign In Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            // color: Colors.white.withOpacity(0.9),
                            color: Colors.white.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Email field is invalid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed:
                                    state is AuthLoading ? null : loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Additional Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 100,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Color.from(
                                      alpha: 1, red: 1, green: 1, blue: 1),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              width: 100,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).push(SignupPage.route()),
                          child: const Text(
                            'Create new account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
