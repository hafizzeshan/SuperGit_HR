import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/screens/dashboard_screens/chat/chat.dart';
import 'package:supergithr/screens/dashboard_screens/home/home.dart';
import 'package:supergithr/screens/dashboard_screens/home/social_posts/social_feed_screen.dart';
import 'package:supergithr/screens/dashboard_screens/keey_aliver.dart';
import 'package:supergithr/screens/dashboard_screens/setting/setting.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/floating_timer_button.dart';
import 'package:supergithr/views/colors.dart';
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
    // Gesture-bar height — ~34 with gesture navigation, 0 with 3 buttons.
    // The bar is grown and padded by this by hand, the same thing Material's
    // own BottomNavigationBar does.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kMainBackgroundColor,
      body: Stack(
        children: [
          _getPage(_selectedIndex),
          // Floating timer/map action button — right side, just above the
          // nav bar. Lives in the Stack so it floats independently of pages.
          // Only shown on the Home tab.
          if (_selectedIndex == 0)
            const Positioned(
              right: 20,
              bottom: 16,
              child: FloatingTimerButton(),
            ),
        ],
      ),
      // Using the Scaffold's own slot rather than stacking the bar over the
      // page: Scaffold then paints its background across the whole window
      // (including behind the gesture bar) and lays the body out above it, so
      // no unpainted strip is left at the bottom.
      bottomNavigationBar:
          isKeyboardVisible
              ? const SizedBox.shrink()
              : Container(
                height: 70 + bottomInset,
                padding: EdgeInsets.only(bottom: bottomInset),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -2),
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
                      label: TranslationKeys.social.tr,
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
    );
  }

  Widget _buildNavItemWithDivider({
    required int index,
    required String icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut, // Bouncy effect
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                )
                : const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: isSelected ? 25 : 23, // Slight size bump
              width: isSelected ? 25 : 23,
              color: isSelected ? kPrimaryColor : Colors.grey.shade400,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleMontserratBold(
                    fontSize: 12,
                    color: kPrimaryColor,
                  ),
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
        return KeepAliveWrapper(child: const SocialFeedScreen());
      case 2:
        return KeepAliveWrapper(child: ChatScreen());
      case 3:
        return KeepAliveWrapper(child: const AboutScreen());
      default:
        return Container();
    }
  }
}
