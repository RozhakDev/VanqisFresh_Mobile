import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ProductImagePlaceholder extends StatelessWidget {
  final double iconSize;
  final Color iconColor;

  const ProductImagePlaceholder({
    super.key,
    this.iconSize = 28,
    this.iconColor = AppColors.textHint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.local_grocery_store_outlined,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}