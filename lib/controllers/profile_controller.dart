import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ProfileController extends GetxController {
  File? profileImage;
  String profileImageUrl = '';
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadProfileImage();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      update();
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;
final String apiKey = dotenv.env['CLOUDINARY_API_KEY']!;


    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/do9dkxsc0/image/upload",
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..fields['api_key'] = apiKey
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respData = await response.stream.bytesToString();
      final jsonData = json.decode(respData);
      return jsonData['secure_url'];
    } else {
      Get.snackbar("Error", "Image upload failed");
      return null;
    }
  }

  Future<void> uploadAndSaveProfileImage() async {
    if (profileImage == null) return;

    final imageUrl = await uploadImageToCloudinary(profileImage!);
    if (imageUrl != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photoUrl', imageUrl);
      profileImageUrl = imageUrl;

      final userId = auth.currentUser?.uid;
      final docRef = firestore.collection('admin').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({'profileImage': imageUrl});
      } else {
        await docRef.set({'profileImage': imageUrl});
      }

      update();

      Get.snackbar(
        "Success",
        "Profile updated",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> reauthenticate(String currentPassword) async {
    try {
      final user = auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      Get.snackbar("Error", "Re-authentication failed");
      return false;
    }
  }

  Future<void> updatePassword() async {
    if (formKey.currentState!.validate()) {
      final success = await reauthenticate(currentPasswordController.text);
      if (success) {
        try {
          await auth.currentUser!.updatePassword(newPasswordController.text);
          Get.snackbar(
            "Success",
            "Password updated",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar("Error", "Failed to update password");
        }
      }
    }
  }

  void loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    profileImageUrl = prefs.getString('profileImageUrl') ?? '';
    update();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
