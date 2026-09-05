import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedImage({
  required String imageUrl,
  double? borderRadius,
  Size? size,
  BoxFit? fit,
}) {
  final radius = borderRadius ?? 50;
  final height = size?.height ?? 100;
  final width = size?.width ?? 100;

  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      errorWidget: (context, url, error) {
        return SizedBox(height: height, width: width);
      },
    ),
  );
}
