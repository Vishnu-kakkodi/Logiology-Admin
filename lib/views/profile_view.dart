import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logiology_admin/controllers/login_controller.dart';
import 'package:logiology_admin/controllers/product_controller.dart';
import 'package:logiology_admin/controllers/profile_controller.dart';
import 'package:logiology_admin/views/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userEmail;
  String? profileImage;

  final ProfileController controller = Get.put(ProfileController());
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email');
      profileImage = prefs.getString('photoUrl');
    });
  }

  void _showPasswordUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passwordField(
                  'Current Password',
                  controller.currentPasswordController,
                ),
                _passwordField(
                  'New Password',
                  controller.newPasswordController,
                ),
                _passwordField(
                  'Confirm Password',
                  controller.confirmPasswordController,
                  validator:
                      (value) =>
                          value == controller.newPasswordController.text
                              ? null
                              : 'Passwords do not match',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.updatePassword();
                  Get.back();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller, {
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator:
            validator ??
            (value) =>
                value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() {
              Get.put(ProductController());
              return HomeView();
            });
          },
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            profileImage != null && profileImage!.isNotEmpty
                                ? NetworkImage(profileImage!)
                                : AssetImage("assets/profile_placeholder.jpg")
                                    as ImageProvider,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          await controller.pickImage();
                          await controller.uploadAndSaveProfileImage();
                          setState(() {
                            profileImage = controller.profileImageUrl;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(userEmail ?? '', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _showPasswordUpdateDialog(context),
                    child: Text("Change Password"),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => loginController.logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Logout"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
