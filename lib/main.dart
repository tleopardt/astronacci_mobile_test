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
  
  // Register AuthController globally
  Get.put(AuthController());
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final auth = Get.put(AuthController());
  final _storage = const FlutterSecureStorage();
  Widget _initialScreen = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: 'token');

    if (token != null) {
      _loadUserInformation();
    } else {
      setState(() {
        _initialScreen = LoginScreen();
      });
    }
  }

  Future<void> _loadUserInformation() async {
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key: 'user_id');
    final email = await _storage.read(key: 'email');
    final username = await _storage.read(key: 'username');

    auth.setAuth(
      resultId: userId.toString(),
      resultToken: token.toString(),
      resultEmail: email.toString(),
      resultName: username.toString(),
    );

    setState(() {
      _initialScreen = const App();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _initialScreen,
    );
  }
}
