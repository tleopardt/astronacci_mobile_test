import 'dart:io';
import 'package:astronacci_mobile_test/utils/helpers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:astronacci_mobile_test/config/auth_controller.dart';
import 'package:astronacci_mobile_test/model/user_model.dart';
import 'package:astronacci_mobile_test/screens/App/profile/edit_profile_screen.dart';
import 'package:astronacci_mobile_test/screens/Auth/login_screen.dart';
import 'package:astronacci_mobile_test/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({ super.key });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final auth = Get.find<AuthController>();
  final secureStorage = FlutterSecureStorage();
  
  List<DetailUser> _detailUser = [];

  @override
  void initState() {
    super.initState();

    loadAllData();
  }

  Future<void> loadAllData() async {
    final payload = {
      "id": auth.userId.value
    };

    final response = await UserEndpoints.getDetailUser(payload);

    if (response != null && response.statusCode == 201) {
      final rawList = response.data;

      setState(() {
        _detailUser = [DetailUser.fromJson(rawList)];
      });

    } else {
      print(payload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting profile info')),
      );
    }
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image'),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (cropped != null) {
      final File imageFile = File(cropped.path);

      final formData = dio.FormData.fromMap({
        'id': auth.userId.value,
        'dir_image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await UserEndpoints.updateProfileImage(formData);

      if (response != null && response.statusCode == 201) {
        loadAllData();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image')),
        );
      }
    }
  }


  Future<void> _logout() async {
    auth.clearAuth();

    await secureStorage.deleteAll();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (_detailUser.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Profile image
            Center(
              child: _detailUser.first.dirImage != '' && _detailUser.first.dirImage != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('${dotenv.env['API_DIRECTORY'] ?? ''}${_detailUser.first.dirImage}'),
                  )
                : CircleAvatar(
                    radius: 60,
                    backgroundColor: generateRandomColor('${_detailUser.first.firstName} ${_detailUser.first.lastName}'),
                    child: Text(
                      getInitials('${_detailUser.first.firstName} ${_detailUser.first.lastName}'),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
            ),

            const SizedBox(height: 12),

            Obx(() => Text(auth.username.value, style: TextStyle(fontSize: 18))),
            Text(auth.email.toString(), style: TextStyle(fontSize: 14)),

            const SizedBox(height: 12),

            // Change Avatar
            GestureDetector(
              onTap: _changeAvatar,
              child: const Text(
                'Change Avatar',
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Edit Profile Info button
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(_detailUser.first)),
                ).then((_) => loadAllData())
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Edit Profile Info'),
            ),

            const SizedBox(height: 16),

            // Logout button
            ElevatedButton(
              onPressed: () => _logout(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
