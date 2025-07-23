import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _forgotPassword() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link to reset password has sent to $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Forgot Password?", style: TextStyle(fontSize: 24)),
                    SizedBox(height: 4),
                    Text("Enter your email, we will send a link for you to reset your password.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || !value.contains('@')
                        ? "Enter a valid email"
                        : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _forgotPassword();
                },
                child: Text("Send"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
