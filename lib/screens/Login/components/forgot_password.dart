import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String message = '';
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                'Enter Your Email',
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                controller: emailController,
              ),
              RaisedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text);
                    setState(() {
                      message = 'Recovery Email Sent to ${emailController.text}';
                    });
                    // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Verification Link is sent to ${emailController.text}')));

                  } catch (e) {
                    print(e);
                    setState(() {
                      message = e.message;
                    });

                    // Get.snackbar('Error',e.message);
                    // Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));

                  }
                },
                child: Text('Reset Password'),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
