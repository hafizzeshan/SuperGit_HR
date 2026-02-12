import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supergithr/views/colors.dart';

class CustomAnimatedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;
  final Widget? separator;
  final Axis scrollDirection;

  const CustomAnimatedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
    this.separator,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        padding: padding,
        physics: physics ?? const BouncingScrollPhysics(),
        shrinkWrap: shrinkWrap,
        controller: controller,
        itemCount: itemCount,
        separatorBuilder: (ctx, idx) => separator!,
        itemBuilder: (context, index) {
          return itemBuilder(context, index)
              .animate()
              .fadeIn(duration: 400.ms, delay: (index * 50).ms)
              .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
        },
      );
    }

    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      controller: controller,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder(context, index)
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 50).ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
      },
    );
  }
}

class CustomAnimatedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const CustomAnimatedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      controller: controller,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        return itemBuilder(context, index)
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 50).ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
      },
    );
  }
}

Future<T?> showCustomAnimatedBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double? heightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height:
            heightFactor != null
                ? MediaQuery.of(context).size.height * heightFactor
                : null,
        decoration: const BoxDecoration(
          gradient: kMainBackgroundGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: child,
      ).animate().slideY(
        begin: 0.5,
        end: 0,
        duration: 400.ms,
        curve: Curves.easeOutQuart,
      );
    },
  );
}
