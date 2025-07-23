import 'package:get/get.dart';

class AuthController extends GetxController {
  var userId = ''.obs;
  var token = ''.obs;
  var email = ''.obs;
  var username = ''.obs;
  var isLoggedIn = false.obs;

  void setAuth({ 
    required String resultId, 
    required String resultToken, 
    required String resultEmail, 
    required String resultName,
  }) {
    userId.value = resultId;
    token.value = resultToken;
    email.value = resultEmail;
    username.value = resultName;
  }

  void clearAuth() {
    userId.value = '';
    token.value = '';
    email.value = '';
    username.value = '';
  }
}