import 'package:flutter/material.dart';
import 'package:xorr/shared/extensions/extensions.dart';
import 'package:xorr/shared/theme/app_colors.dart';
import 'package:xorr/shared/ui/loaders.dart';

FilledButton appButton({
  required String text,
  required VoidCallback onPressed,
  Size? size,
  bool? isLoading,
}) {
  return FilledButton(
    onPressed: onPressed,

    style: FilledButton.styleFrom(
      minimumSize: size ?? Size(.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
    ),
    child: Row(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        if (isLoading == true) ...[
          appLoader(
            size: 15,
            strokeWidth: 2,
            color: Extensions.textColorFor(AppColors.primary),
          ),
          const SizedBox(width: 10),
        ],
        Text(text),
      ],
    ),
  );
}
