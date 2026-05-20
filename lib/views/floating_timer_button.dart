import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/clock_in_map.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

/// A center-bottom floating action button that reflects the clock-in timer
/// state: shows the live elapsed time when clocked in, or a map icon when not.
/// Tapping always opens the clock-in Map screen (unless [onTap] is overridden).
class FloatingTimerButton extends StatelessWidget {
  /// Override the default tap action (e.g. on the Map screen itself, where
  /// re-navigating would just stack another map). Defaults to opening the map.
  final VoidCallback? onTap;

  const FloatingTimerButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.find<AttendanceController>();

    return Obx(() {
      final isActive = controller.clockInTime.value != null;
      final elapsed = controller.elapsedTime.value;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
        child:
            isActive
                ? _activePill(key: const ValueKey('active'), elapsed: elapsed)
                : _idleButton(key: const ValueKey('idle')),
      );
    });
  }

  void _handleTap() {
    if (onTap != null) {
      onTap!();
    } else {
      Get.to(() => const ClockInMapScreen());
    }
  }

  Widget _activePill({required Key key, required String elapsed}) {
    return Material(
      key: key,
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.5),
      color: kPrimaryColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing live dot (continuous "live" indicator)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 700.ms)
                  .then()
                  .fade(begin: 1.0, end: 0.25, duration: 700.ms)
                  .scaleXY(begin: 1.0, end: 0.6, duration: 700.ms),
              const SizedBox(width: 8),
              const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                elapsed,
                style: textStyleMontserratBold(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idleButton({required Key key}) {
    return Material(
      key: key,
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.5),
      color: kPrimaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.location_on_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
