import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/screens/dashboard_screens/chat/chat.dart';
import 'package:supergithr/screens/dashboard_screens/home/home.dart';
import 'package:supergithr/screens/dashboard_screens/keey_aliver.dart';
import 'package:supergithr/screens/dashboard_screens/requests/request.dart';
import 'package:supergithr/screens/dashboard_screens/setting/setting.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';

class DashBorad extends StatefulWidget {
  int index;
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
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Expanded(child: _getPage(_selectedIndex)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: isKeyboardVisible ? 0 : 70,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Card(
                  elevation: 10,
                  color: kPrimaryColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildNavItemWithDivider(
                          index: 0,
                          icon: AppAssets.home,
                          label: TranslationKeys.home.tr,
                          isEdge: true, // No padding for the first item
                        ),
                      ),
                      Expanded(
                        child: _buildNavItemWithDivider(
                          index: 1,
                          icon: AppAssets.approved,
                          label: TranslationKeys.requests.tr,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItemWithDivider(
                          index: 2,
                          icon: AppAssets.chat,
                          label: TranslationKeys.chat.tr,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItemWithDivider(
                          index: 3,
                          icon: AppAssets.setting,
                          label: TranslationKeys.setting.tr,
                          isEdge: true, // No padding for the last item
                        ),
                      ),
                    ],
                  ),
                ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            Container(
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(
                icon,
                height: 23,
                width: 23,
                color: isSelected ? whiteColor : null,
              ),
            )
          else
            Image.asset(
              icon,
              height: 23,
              width: 23,
              color: isSelected ? whiteColor : null,
            ),
          const SizedBox(height: 4),
          kText(
            text: label,
            style:
            // isSelected
            //     ? textStyleMontserratBold(fontSize: 12, color: mainBlackcolor)
            //     :
            textStyleMontserratBold(
              fontSize: 11,
              color: isSelected ? whiteColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return KeepAliveWrapper(child: const HomeScreen());
      case 1:
        return KeepAliveWrapper(child: const RequestScreen());
      case 2:
        return KeepAliveWrapper(child: ChatScreen());
      case 3:
        return KeepAliveWrapper(child: const AboutScreen());
      default:
        return Container();
    }
  }
}
