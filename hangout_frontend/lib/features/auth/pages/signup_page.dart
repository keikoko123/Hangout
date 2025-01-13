import 'package:flutter/material.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/auth/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const SignupPage(),
      );
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    // formKey.currentState!.dispose();
    super.dispose();
  }

  void signUpUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            name: nameController.text.trim(),
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
        } else if (state is AuthSignUp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created! Login!"),
            ),
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
                  'Sign Up. ',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Release Your Mind, Reshape Your Lifestyle',
                  style: TextStyle(
                    fontSize: 19,
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
                          value.trim().length < 8) {
                        return 'Password filed is invalid';
                      }
                      return null;
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    // validator: (value) {
                    //   if (value!.isEmpty || value == null) {
                    //     return 'Name cannot be empty';
                    //   }
                    //   return null;
                    // }
                    validator: (value) => (value!.isEmpty || value == null)
                        ? 'Name cannot be empty'
                        : null),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: signUpUser,
                    child: const Text('Sign Up',
                        style: TextStyle(fontSize: 22, color: Colors.white))),
                const SizedBox(height: 10),
                GestureDetector(
                  //static MaterialPageRoute route() => MaterialPageRoute(
                  onTap: () => {Navigator.of(context).push(LoginPage.route())},
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account?  ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'SIGN-IN',
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
    ));
  }
}
