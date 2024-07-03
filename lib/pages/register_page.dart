import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_notes/components/my_textfield.dart';
import 'package:my_notes/pages/sign_in_page.dart';
import 'package:my_notes/widgets/common_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (newUser.user != null) {
          // Send email verification
          await newUser.user!.sendEmailVerification();

          // Show a toast message
          Fluttertoast.showToast(
            msg:
                "A verification email has been sent. Please verify your email.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );

          // Navigate back to the sign-in page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInPage(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage =
              'The email address is already in use by another account.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'An unknown error occurred.';
        }
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Show general error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppbar("Sign Up"),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: reuseableText(
                        "Enter your details below and sign up for free"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reuseableText("Username"),
                        MyTextField(
                          obscureText: false,
                          controller: _usernameController,
                          textType: "Username",
                          hintText: "Enter Your Username",
                          iconName: Icons.confirmation_number_sharp,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        reuseableText("E-mail"),
                        MyTextField(
                          obscureText: false,
                          controller: _emailController,
                          textType: "Email",
                          hintText: "Enter your email",
                          iconName: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        reuseableText("Password"),
                        MyTextField(
                          controller: _passwordController,
                          textType: "Password",
                          hintText: "Enter your Password",
                          iconName: Icons.password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        reuseableText("Confirm Password"),
                        MyTextField(
                          controller: _confirmPasswordController,
                          textType: "Password",
                          hintText: "Confirm Password",
                          iconName: Icons.password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        reuseableText(
                            "By creating an account you have to agree to our terms & conditions"),
                        const SizedBox(height: 25),
                        loginAndRegButton(
                          "Sign Up",
                          "log in",
                          _signUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
