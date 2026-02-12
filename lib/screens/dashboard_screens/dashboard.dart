import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/screens/dashboard_screens/chat/chat.dart';
import 'package:supergithr/screens/dashboard_screens/home/home.dart';
import 'package:supergithr/screens/dashboard_screens/home/leave_summary/show_leavers.dart';
import 'package:supergithr/screens/dashboard_screens/keey_aliver.dart';
import 'package:supergithr/screens/dashboard_screens/requests/request.dart';
import 'package:supergithr/screens/dashboard_screens/setting/setting.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';

class DashBorad extends StatefulWidget {
  final int index;
  DashBorad({super.key, required this.index});
  @override
  _DashBoradState createState() => _DashBoradState();
}

class _DashBoradState extends State<DashBorad> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kMainBackgroundColor,
      body: Stack(
        children: [
          _getPage(_selectedIndex),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: isKeyboardVisible ? 0 : 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.9,
                ), // Slightly transparent pill
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItemWithDivider(
                    index: 0,
                    icon: AppAssets.home,
                    label: TranslationKeys.home.tr,
                  ),
                  _buildNavItemWithDivider(
                    index: 1,
                    icon: AppAssets.approved,
                    label: TranslationKeys.requests.tr,
                  ),
                  _buildNavItemWithDivider(
                    index: 2,
                    icon: AppAssets.chat,
                    label: TranslationKeys.chat.tr,
                  ),
                  _buildNavItemWithDivider(
                    index: 3,
                    icon: AppAssets.setting,
                    label: TranslationKeys.setting.tr,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithDivider({
    required int index,
    required String icon,
    required String label,
    bool isEdge = false,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut, // Bouncy effect
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                )
                : const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: isSelected ? 26 : 24, // Slight size bump
              width: isSelected ? 26 : 24,
              color: isSelected ? kPrimaryColor : Colors.grey.shade400,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: textStyleMontserratBold(
                  fontSize: 12,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return KeepAliveWrapper(child: const HomeScreen());
      case 1:
        return KeepAliveWrapper(child: const LeaveSummaryScreen(showBackButton: false));
      case 2:
        return KeepAliveWrapper(child: ChatScreen());
      case 3:
        return KeepAliveWrapper(child: const AboutScreen());
      default:
        return Container();
    }
  }
}
