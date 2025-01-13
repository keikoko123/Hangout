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
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // formKey.currentState!.dispose();
    super.dispose();
  }

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
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text("Login successful!"),
            //   ),
            // );
            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hangout  ',
                    style: TextStyle(
                      fontSize: 50,
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
                  const SizedBox(height: 20),
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value == null ||
                            !value.contains('@')) {
                          return 'Email filed is invalid';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value == null ||
                            value.trim().length < 6) {
                          return 'Password filed is invalid';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: loginUser,
                      child: const Text('Login',
                          style: TextStyle(fontSize: 22, color: Colors.white))),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        {Navigator.of(context).push(SignupPage.route())},
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\`t have an account?  ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'SIGN-UP',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
