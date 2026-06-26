import 'package:firebase_project/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailTextEditingController = TextEditingController();

  final TextEditingController _passwordTextEditingController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool  _signUpInProgress = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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

              Visibility(
                visible: _signUpInProgress == false,
                replacement: Center(
                  child: CircularProgressIndicator(),
                ),
                child: FilledButton(
                  onPressed: _onTabSignUpButton,
                  child: const Text('Sign Up'),
                ),
              ),

              TextButton(
                onPressed: _onTabSignInButton,
                child: const Text(
                  'Already have an account? Sign In',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTabSignUpButton() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailTextEditingController.text.trim();
      final password = _passwordTextEditingController.text;

      try {
        _signUpInProgress =true;
        setState(() {});
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _clearTextFields();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully'),
          ),
        );
        Navigator.pushNamed(context, '/sign-in');
      } on FirebaseException catch (e) {
        debugPrint(e.stackTrace.toString());
        showSnackBarMassage(context, e.message ?? 'Something went wrong');
      }on Exception catch(e){
        showSnackBarMassage(context, e.toString());
      }finally{
        _signUpInProgress = false;
        setState(() {});
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

  void _onTabSignInButton() {
    Navigator.pop(context);
  }

  void _clearTextFields(){
    _emailTextEditingController.clear();
    _passwordTextEditingController.clear();

}
  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

}