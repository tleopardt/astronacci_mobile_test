import 'package:astronacci_mobile_test/screens/App/app_screen.dart';
import 'package:astronacci_mobile_test/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astronacci_mobile_test/config/auth_controller.dart';

// Define a consistent gap size

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final auth = Get.put(AuthController());

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _birthdate = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isObscure = true;

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _birthdate.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> handleRegister(BuildContext context) async {
    final payload = {
      "first_name": _firstName.text.trim(),
      "last_name": _lastName.text.trim(),
      "birth_date": _birthdate.text,
      "phone": _phone.text.trim(),
      "email": _email.text.trim(),
      "password": _password.text,
    };
    
    final response = await ApiEndpoints.register(payload);

    if (response != null && response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully Registered, Logging in..')),
      );

      handleLogin(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?.data['error'])),
      );

      handleLogin(context);
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    final payload = {
      "email": _email.text.trim(),
      "password": _password.text,
    };
    
    final response = await ApiEndpoints.login(payload);

    if (response != null && response.statusCode == 200) {
      final authData = response.data['auth'];
      
      if (authData == null) {
        (
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Direct login failed')),
          )
        );
      }

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
        SnackBar(content: Text(response?.data.error)),
      );
    }
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input fields with consistent spacing
              ...[
                _input('First Name', _firstName),
                _input('Last Name', _lastName),
                _input('Birthdate', _birthdate, readOnly: true, onTap: _pickDate),
                _input('Phone', _phoneController, keyboardType: TextInputType.phone),
                _input('Email', _email, keyboardType: TextInputType.emailAddress),
                TextFormField(
                  controller: _password,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (val) =>
                      val != null && val.length >= 6
                          ? null
                          : 'Min 6 characters',
                ),
              ].expand((field) => [field, SizedBox(height: 12)]),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => handleRegister(context),
                child: Text('Register'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Obx(() => Text('Counter: ${controller.count}')),
