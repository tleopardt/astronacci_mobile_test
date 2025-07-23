import 'package:astronacci_mobile_test/config/api.dart';
import 'package:astronacci_mobile_test/config/auth_controller.dart';
import 'package:astronacci_mobile_test/screens/App/app_screen.dart';
import 'package:astronacci_mobile_test/screens/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.initialize();
  await dotenv.load(fileName: ".env");
  
  // Register AuthController globally - only once
  Get.put(AuthController());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Changed from MaterialApp to GetMaterialApp
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),  // Use a separate wrapper widget
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final auth = Get.find<AuthController>();  // Use Get.find instead of Get.put
  final _storage = const FlutterSecureStorage();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final token = await _storage.read(key: 'token');

      if (token != null) {
        final userId = await _storage.read(key: 'user_id');
        final email = await _storage.read(key: 'email');
        final username = await _storage.read(key: 'username');

        auth.setAuth(
          resultId: userId ?? '',
          resultToken: token,
          resultEmail: email ?? '',
          resultName: username ?? '',
        );
      }
    } catch (e) {
      // Handle any storage errors
      print('Error reading from secure storage: $e');
    }

    if (mounted) {  // Check if widget is still mounted before setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Use GetX Obx for reactive UI updates
    return Obx(() {
      return auth.isLoggedIn.value ? const App() : LoginScreen();
    });
  }
}