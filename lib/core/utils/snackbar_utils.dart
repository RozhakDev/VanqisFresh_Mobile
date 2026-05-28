import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Menyediakan tipe snackbar yang didukung aplikasi.
///
/// Tipe ini menentukan warna dan ikon pesan.
enum SnackbarType { success, error, info, warning }

/// Menampilkan snackbar dengan gaya yang konsisten.
///
/// Utilitas ini dipakai untuk pesan sukses, error, info, dan peringatan.
class SnackbarUtils {
  static OverlayEntry? _currentEntry;

  /// Menampilkan komponen sesuai konteks yang diberikan.
  ///
  /// Dipakai saat UI perlu dibuka dari lokasi lain.
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color accentColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        accentColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.error:
        accentColor = AppColors.error;
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.warning:
        accentColor = AppColors.accentOrange;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
      default:
        accentColor = AppColors.accentBlue;
        icon = Icons.info_outline_rounded;
        break;
    }

    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topOffset = mediaQuery.padding.top + 12;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: topOffset,
          left: 16,
          right: 16,
          child: SafeArea(
            top: false,
            bottom: false,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -10, end: 0),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, offsetY, child) {
                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: child,
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message.replaceAll('\n', ' '),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (action != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            entry.remove();
                            if (identical(_currentEntry, entry)) {
                              _currentEntry = null;
                            }
                            action.onPressed();
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            foregroundColor: accentColor,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                          child: Text(action.label),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (identical(_currentEntry, entry)) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }
}
