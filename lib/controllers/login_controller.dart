import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logiology_admin/views/home_view.dart';
import 'package:logiology_admin/views/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final uid = prefs.getString('uid');
    if (uid != null && uid.isNotEmpty) {
      Get.offAll(() => HomeView());
    }
  }

  void loginWithFirebase() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter email and password");
      return;
    }

    try {
      isLoading.value = true;

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', user.uid);
        await prefs.setString('email', user.email ?? "");

        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('admin')
                .doc(user.uid)
                .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final photoUrl = data?['profileImage'] ?? "";

          await prefs.setString('photoUrl', photoUrl);
          await prefs.setString('photoUrl', photoUrl ?? "");
        } else {
          await prefs.setString('photoUrl', '');
        }

        Get.to(() => HomeView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await FirebaseAuth.instance.signOut();

      Get.offAll(() => LoginScreen());

      Get.snackbar(
        "Logged out",
        "You have been logged out successfully",
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        "Logout Error",
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }
}
