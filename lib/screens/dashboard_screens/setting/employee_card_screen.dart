import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/appBar.dart';

class EmployeeCardScreen extends StatelessWidget {
  const EmployeeCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.userModel.value;

    final String fullName =
        "${user.firstNameEn ?? ""} ${user.lastNameEn ?? ""}".trim();
    final String initials =
        (user.firstNameEn?.isNotEmpty == true ? user.firstNameEn![0] : "") +
        (user.lastNameEn?.isNotEmpty == true ? user.lastNameEn![0] : "");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarrWitoutAction(
        title: TranslationKeys.employeeCard.tr,
        backgroundColor: const Color(0xFF0ea5e9),
        titleColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              // Top Wave Section
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      height: Get.height * 0.32,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0ea5e9), Color(0xFF38bdf8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 25, left: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.blur_on,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  kText(
                                    text: TranslationKeys.idealClinic.tr,
                                    fSize: 19.0,
                                    fWeight: FontWeight.w900,
                                    tColor: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  kText(
                                    text: TranslationKeys.healthcareServices.tr,
                                    fSize: 11.0,
                                    tColor: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Circle
                  Positioned(
                    bottom: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF38bdf8), Color(0xFF0ea5e9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: kText(
                            text: initials.toUpperCase(),
                            fSize: 50.0,
                            fWeight: FontWeight.w800,
                            tColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              // Name & Title
              kText(
                text: fullName.toUpperCase(),
                fSize: 28.0,
                fWeight: FontWeight.w900,
                tColor: Colors.black,
              ),
              const SizedBox(height: 4),
              kText(
                text: (user.jobTitle ?? TranslationKeys.softwareDeveloper.tr).toUpperCase(),
                fSize: 13.0,
                fWeight: FontWeight.w600,
                tColor: Colors.grey.shade600,
                letterSpacing: 2.5,
              ),

              const SizedBox(height: 35),

              // Info entries
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: Column(
                  children: [
                    _infoEntry(TranslationKeys.idNo.tr, user.employeeCode ?? "BYTE0006"),
                    const SizedBox(height: 12),
                    _infoEntry(TranslationKeys.email.tr, user.email ?? "uzairmunir@gmail.com"),
                    const SizedBox(height: 12),
                    _infoEntry(TranslationKeys.gender.tr, (user.gender ?? TranslationKeys.male).tr),
                    const SizedBox(height: 12),
                    _infoEntry(TranslationKeys.phone.tr, user.mobileNumber ?? "0534543423"),
                    const SizedBox(height: 12),
                    _infoEntry(TranslationKeys.department.tr, TranslationKeys.softwareDevelopment.tr),
                  ],
                ),
              ),

              const Spacer(),

              // Barcode - 100% Visual Match with Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(60, (index) {
                    bool isGap;
                    double width;

                    // Specific pattern to mimic Code 128 look from image
                    if (index % 2 == 0) {
                      isGap = false;
                      // Vary widths: some thin (1.5), some medium (2.5), some thick (4.0)
                      if (index % 10 == 0)
                        width = 4.0;
                      else if (index % 4 == 0)
                        width = 1.2;
                      else if (index % 6 == 0)
                        width = 3.0;
                      else
                        width = 2.0;
                    } else {
                      isGap = true;
                      // Vary gaps to match image rhythm
                      if (index % 5 == 0)
                        width = 3.0;
                      else if (index % 7 == 0)
                        width = 1.0;
                      else
                        width = 2.0;
                    }

                    return isGap
                        ? SizedBox(width: width)
                        : Container(
                          width: width,
                          height: 40,
                          color: Colors.black,
                        );
                  }),
                ),
              ),

              const SizedBox(height: 25),

              // Bottom Wave
              ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0284c7), Color(0xFF0369a1)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double width) =>
      Container(width: width, height: 45, color: Colors.black);
  Widget _gap(double width) => SizedBox(width: width);

  Widget _infoEntry(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: kText(
            text: label,
            fSize: 14.5,
            tColor: Colors.black54,
            fWeight: FontWeight.w500,
          ),
        ),
        kText(text: " : ", fSize: 14.5, tColor: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: kText(
            text: value,
            fSize: 14.5,
            tColor: Colors.black,
            fWeight: FontWeight.w600,
            textoverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // Start point for the rounded corner

    // Exact "cut" design: Rounded bottom-left corner
    path.quadraticBezierTo(0, size.height, 50, size.height);

    // Flat part before the curve
    path.lineTo(size.width * 0.3, size.height);

    // Smooth wave rising up towards the right
    var control = Offset(size.width * 0.5, size.height);
    var end = Offset(size.width, size.height * 0.6);

    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height); // Start at bottom-left corner

    // Clean convex wave curve to match the picture exactly
    var control = Offset(size.width * 0.3, size.height * -0.1);
    var end = Offset(size.width, size.height * 0.2);

    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
