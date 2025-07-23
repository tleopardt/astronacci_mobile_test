import 'package:astronacci_mobile_test/config/auth_controller.dart';
import 'package:astronacci_mobile_test/model/user_model.dart';
import 'package:astronacci_mobile_test/services/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final DetailUser userData;

  const EditProfileScreen(this.userData, {super.key});
  
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final auth = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _birthdate = TextEditingController();
  final _phone = TextEditingController();
  
  @override
  void initState() {
    super.initState();

    _firstName.text = widget.userData.firstName;
    _lastName.text = widget.userData.lastName;
    _phone.text = widget.userData.phone;

    final date = DateTime.parse(widget.userData.birthDate).toLocal();
    _birthdate.text = DateFormat('yyyy-MM-dd').format(date);
  }

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

  Future<void> handleSaveChanges(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "id": auth.userId.value,
        "first_name": _firstName.text.trim(),
        "last_name": _lastName.text.trim(),
        "birth_date": _birthdate.text.trim(),
        "phone": _phone.text.trim(),
      };

      final response = await UserEndpoints.updateProfile(payload);

      if (response != null && response.statusCode == 201) {
        final authData = response.data['auth'];

        if (authData == null) {
          (
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile info not found')),
            )
          );
        }

        auth.setAuth(
          resultId: auth.userId.value,
          resultToken: auth.token.value,
          resultEmail: auth.email.value,
          resultName: authData['username'],
        );
        
        Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Widget _input(String label, TextEditingController controller,
      {bool obscure = false, bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
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
                _input('Birthdate', _birthdate,
                    readOnly: true, onTap: _pickDate),
                _input('Phone', _phone),
              ].expand((field) => [field, SizedBox(height: 12)]),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => handleSaveChanges(context),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Obx(() => Text('Counter: ${controller.count}')),
