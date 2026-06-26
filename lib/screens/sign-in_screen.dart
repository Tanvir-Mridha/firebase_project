import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/utils/snack_bar.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailTextEditingController = TextEditingController();

  final TextEditingController _passwordTextEditingController = TextEditingController();


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                controller: _emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Email',
                ),
                validator: _validateEmail
              ),

              TextFormField(
                controller: _passwordTextEditingController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password',
                ),
                validator: _validatePassword
              ),

              FilledButton(
                onPressed: _onTabSignInButton,
                child: const Text('Sign In'),
              ),

              TextButton(
                onPressed: _onTabSignUpButton,
                child: const Text(
                  'Don\'t have an account? Sign Up',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTabSignInButton() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailTextEditingController.text.trim();
      final password = _passwordTextEditingController.text;

      print('Email: $email');
      print('Password: $password');

      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        showSnackBarMassage(context, 'Sign in successful');
        Navigator.pushNamed(context, '/home');

      }on FirebaseException catch(e) {
        showSnackBarMassage(context, e.message?? 'Something went wrong!');

      }on Exception catch(e){
        debugPrint(e.toString());

      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void _onTabSignUpButton() {
    Navigator.pushNamed( context, '/sign-up');
  }

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }
}