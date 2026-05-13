import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Menjalankan inisialisasi awal dan memulai aplikasi.
///
/// Dipanggil saat aplikasi pertama kali dijalankan.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: VanqisFreshApp(),
    ),
  );
}

/// Menjalankan aplikasi dengan konfigurasi router dan tema utama.
///
/// Widget ini menjadi root dari seluruh tampilan aplikasi.
class VanqisFreshApp extends ConsumerWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat VanqisFreshApp perlu dibuat dengan nilai awal.
  const VanqisFreshApp({super.key});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'VanqisFresh',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
