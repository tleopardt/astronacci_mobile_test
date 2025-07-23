import 'package:astronacci_mobile_test/config/auth_controller.dart';
import 'package:astronacci_mobile_test/screens/Auth/forgot_password_screen.dart';
import 'package:astronacci_mobile_test/screens/Auth/register_screen.dart';
import 'package:astronacci_mobile_test/screens/App/app_screen.dart';
import 'package:astronacci_mobile_test/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = Get.put(AuthController());
  final secureStorage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  Future<void> handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
      };
      
      final response = await ApiEndpoints.login(payload);

      if (response != null && response.statusCode == 200) {
        final authData = response.data['auth'];
        
        if (authData == null) {
          (
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to login: User info not found')),
            )
          );
        }
        
        await Future.wait([
          secureStorage.write(key: 'token', value: authData['token']),
          secureStorage.write(key: 'user_id', value: authData['user_id'].toString()),
          secureStorage.write(key: 'email', value: authData['email']),
          secureStorage.write(key: 'username', value: authData['username']),
        ]);

        auth.setAuth(
          resultId: authData['user_id'].toString(),
          resultToken: authData['token'],
          resultEmail: authData['email'],
          resultName: authData['username'],
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => App()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Login Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome Back", style: TextStyle(fontSize: 24)),
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
              SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) =>
                    value != null && value.length >= 3
                        ? null
                        : "Password must be 3+ characters",
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text("Forgot Password?"),
                ),
              ),
              SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => handleLogin(context),
                child: Text("Login"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text("Register"),
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
