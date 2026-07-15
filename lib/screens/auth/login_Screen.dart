import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supergithr/controllers/login_controller.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/language_selection_bottom_sheet.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: "LoginFormKey");

  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode employeeCodeFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool obscureText = true;

  // ✅ Initialize GetX Controller
  LoginController loginController = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('saved_employee_code') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    if (savedCode.isNotEmpty) {
      employeeCodeController.text = savedCode;
    }
    if (savedPassword.isNotEmpty) {
      passwordController.text = savedPassword;
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_employee_code',
      employeeCodeController.text.trim(),
    );
    await prefs.setString('saved_password', passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(gradient: linearGradient2),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Modern Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // 🔹 App Logo
                        Hero(
                          tag: "logo",
                          child: Container(
                            height: 90,
                            width: 90,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(AppAssets.logo),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Title & Subtitle
                        Text(
                          "SuperGit HR",
                          style: textStyleMontserratBold(
                            color: appblueColor,
                            fontSize: 26.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          TranslationKeys.welcomeBackLoginToContinue.tr,
                          textAlign: TextAlign.center,
                          style: textStyleMontserratMiddle(
                            color: Colors.grey.shade600,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // 🔹 Employee Code Field
                        CustomTextField(
                          required: true,
                          focusNode: employeeCodeFocus,
                          controller: employeeCodeController,
                          maxLength: 50,
                          label: TranslationKeys.employeeID.tr,
                          hint: TranslationKeys.enterYourEmployeeID.tr,
                          keyboardType: TextInputType.text,
                          backGroundcolor: Colors.grey.shade50,
                          prefix: Icon(
                            Icons.person_outline_rounded,
                            color: kPrimaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Password Field
                        CustomTextField(
                          required: true,
                          controller: passwordController,
                          focusNode: passwordFocus,
                          maxLines: 1,
                          label: TranslationKeys.password.tr,
                          hint: TranslationKeys.password.tr,
                          isHide: obscureText,
                          backGroundcolor: Colors.grey.shade50,
                          prefix: Icon(
                            Icons.lock_outline_rounded,
                            color: kPrimaryColor,
                            size: 22,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            child: Icon(
                              obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // 🔹 Login Button
                        Obx(() {
                          return LoadingButton(
                            isLoading: loginController.isLoading.value,
                            text:
                                loginController.isLoading.value
                                    ? TranslationKeys.loading.tr
                                    : TranslationKeys.login.tr,
                            width: double.infinity,
                            height: 52,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _saveCredentials();
                                final payload = {
                                  "employee_code":
                                      employeeCodeController.text.trim(),
                                  "password": passwordController.text.trim(),
                                };
                                loginController.loginUser(payload);
                              } else {
                                UIHelper.showMySnak(
                                  title: TranslationKeys.error.tr,
                                  message:
                                      TranslationKeys
                                          .pleaseFillAllFieldsCorrectly
                                          .tr,
                                  isError: true,
                                );
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Language Selection Button
                GestureDetector(
                  onTap: () {
                    LanguageSelectionBottomSheet.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.translate,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TranslationKeys.changeLanguage.tr,
                          style: textStyleMontserratMiddle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Footer text
                Text(
                  "© 2026 SuperGit HR. ${TranslationKeys.allRightsReserved.tr}",
                  style: textStyleMontserratRegular(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
