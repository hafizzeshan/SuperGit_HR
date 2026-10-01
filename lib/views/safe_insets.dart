import 'package:flutter/material.dart';

/// Helpers for the space at the bottom of the screen that content must not
/// hide behind.
///
/// Two different insets matter and they are easy to confuse:
///  * `viewPadding.bottom` — the gesture bar / home indicator. It is ~34 on a
///    gesture-navigation phone and 0 on one with 3-button navigation, so it
///    must never be hard-coded.
///  * `viewInsets.bottom` — the on-screen keyboard.
extension SafeInsets on BuildContext {
  /// Gesture bar / home indicator height. Zero with button navigation.
  double get gestureInset => MediaQuery.viewPaddingOf(this).bottom;

  /// Keyboard height, zero when it is closed.
  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  /// Bottom padding for a scrollable list, clearing the gesture bar.
  ///
  /// It does not add room for the dashboard nav bar: that lives in the
  /// Scaffold's `bottomNavigationBar` slot, so the body is already laid out
  /// above it. On a pushed route the inset is simply the gesture bar.
  double listBottomInset([double extra = 16]) => gestureInset + extra;

  /// Padding for a modal bottom sheet: clears the keyboard when it is open and
  /// the gesture bar when it is not.
  EdgeInsets sheetPadding({
    double horizontal = 20,
    double top = 20,
    double bottom = 24,
  }) => EdgeInsets.fromLTRB(
    horizontal,
    top,
    horizontal,
    bottom + keyboardInset + gestureInset,
  );
}
