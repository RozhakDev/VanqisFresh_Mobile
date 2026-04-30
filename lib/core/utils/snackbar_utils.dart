import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, info, warning }

class SnackbarUtils {
  static Color _foregroundFor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : AppColors.textPrimary;
  }

  static SnackBarAction? _actionWithForeground(
    SnackBarAction? action,
    Color foreground,
  ) {
    if (action == null) return null;
    if (action.textColor != null && action.disabledTextColor != null) return action;

    return SnackBarAction(
      label: action.label,
      onPressed: action.onPressed,
      textColor: action.textColor ?? foreground,
      disabledTextColor: action.disabledTextColor ?? foreground.withValues(alpha: 0.55),
    );
  }

  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        bgColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.error:
        bgColor = AppColors.error;
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.warning:
        bgColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
      default:
        bgColor = AppColors.info;
        icon = Icons.info_outline_rounded;
        break;
    }

    final fgColor = _foregroundFor(bgColor);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: fgColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.replaceAll('\n', ' '),
                style: GoogleFonts.inter(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 6,
        duration: duration,
        action: _actionWithForeground(action, fgColor),
      ),
    );
  }
}