import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supergithr/controllers/login_controller.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/custom_text_field.dart';
import 'package:supergithr/views/language_selection_bottom_sheet.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: "LoginFormKey");

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool obscureText = true;

  // ✅ Initialize GetX Controller
  LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: TranslationKeys.login.tr,
        titlefontSize: 18.0,
        leadingWidget: const SizedBox(),
        actionwidget: IconButton(
          onPressed: () {
            LanguageSelectionBottomSheet.show(context);
          },
          icon: const Icon(Icons.translate),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 100.w),
                        const SizedBox(height: 15),
                        // 🔹 App Logo
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: Material(
                            color: Colors.transparent,
                            child: Hero(
                              tag: "logo",
                              child: Image.asset(AppAssets.logo),
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        // 🔹 Email Field
                        CustomTextField(
                          required: true,
                          focusNode: emailFocus,
                          controller: emailController,
                          maxLength: 50,
                          hint: TranslationKeys.email.tr,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 13),

                        // 🔹 Password Field
                        CustomTextField(
                          required: true,
                          controller: passwordController,
                          focusNode: passwordFocus,
                          maxLines: 1,
                          hint: TranslationKeys.password.tr,
                          isHide: obscureText,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            child: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                        // const SizedBox(height: 10),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: kText(
                        //     text: "Forget Password?",
                        //     tColor: Colors.grey.shade600,
                        //     fSize: 14.0,
                        //   ),
                        // ),
                        const Spacer(flex: 2),

                        // 🔹 Login Button
                        Obx(() {
                          return LoadingButton(
                            isLoading: loginController.isLoading.value,
                            text:
                                loginController.isLoading.value
                                    ? TranslationKeys.loading.tr
                                    : TranslationKeys.login.tr,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                final payload = {
                                  "email": emailController.text.trim(),
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
