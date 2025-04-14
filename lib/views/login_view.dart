import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logiology_admin/views/widgets/text_field.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());
  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 80),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Enter email...",
                    labelText: "Email",
                    controller: controller.emailController,
                    obscureText: false,
                    validator:
                        (value) => value!.isEmpty ? "Please enter email" : null,
                  ),

                  SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Enter password...",
                    labelText: "Password",
                    controller: controller.passwordController,
                    obscureText: true,
                    validator:
                        (value) =>
                            value!.isEmpty ? "Please enter password" : null,
                  ),

                  SizedBox(height: 70),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : () {
                                if (_loginFormKey.currentState!.validate()) {
                                  controller.loginWithFirebase();
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8687E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child:
                          controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: 40),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/google_icon.png',
                      height: 35,
                      width: 35,
                    ),
                    label: Text(
                      'Login with Google',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 54),
                      side: BorderSide(color: Color(0xFF8875FF), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
