import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholderWidget;
  final Widget? errorWidget;
  final int quality;
  final double scale;

  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.scale = 1.0,
    this.quality = 5, // Default quality to 50% if supported

    this.fit = BoxFit.cover,
    this.placeholderWidget,
    this.errorWidget,
  });

  String get lowQualityImageUrl {
    return "$imageUrl?q=$quality"; // Modify according to your server's quality parameter
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: lowQualityImageUrl,
      scale: scale,
      fit: fit,
      imageBuilder:
          (context, imageProvider) => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(fit: fit, image: imageProvider),
            ),
          ),
      placeholder:
          (context, url) =>
              placeholderWidget ??
              SizedBox(
                width: width,
                height: height,
                //  color: Colors.grey[300], // Default placeholder color
                child: const Center(
                  child: CircularProgressIndicator(color: appButtonColor),
                ), // Default loader
              ),
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: appdarkIconColor,
                    child: Icon(Icons.error, color: redColor, size: 30),
                  ),
                  UIHelper.verticalSpaceSm10,
                  kText(text: error.toString()),
                ],
              ),
    );
  }
}

class CustomCachedNetworkImage2 extends StatelessWidget {
  final String imageUrl;
  final double size; // Use size instead of separate width and height
  final BoxFit fit;
  final Widget? placeholderWidget;
  final Widget? errorWidget;
  final int quality;

  const CustomCachedNetworkImage2({
    super.key,
    required this.imageUrl,
    this.size = 100,
    this.quality = 5, // Default quality to 50% if supported

    this.fit = BoxFit.cover,
    this.placeholderWidget,
    this.errorWidget,
  });

  String get lowQualityImageUrl {
    return "$imageUrl?q=$quality"; // Modify according to your server's quality parameter
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: lowQualityImageUrl,
      imageBuilder:
          (context, imageProvider) =>
              CircleAvatar(radius: size, backgroundImage: imageProvider),
      progressIndicatorBuilder:
          (context, url, downloadProgress) => CircleAvatar(
            radius: size,
            backgroundColor: whiteColor,
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
              color: appButtonColor,
            ),
          ),
      errorWidget:
          (context, url, error) => const CircleAvatar(
            radius: 30,
            backgroundColor: whiteColor,
            child: CircleAvatar(
              backgroundColor: appdarkIconColor,
              child: Icon(Icons.error, color: redColor, size: 30),
            ),
          ),
    );
  }
}
