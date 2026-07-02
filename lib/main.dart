import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/supabase_config.dart';
import 'core/guards/route_guard.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/screens/login_email_screen.dart';
import 'features/auth/screens/login_ortu_screen.dart';
import 'features/auth/screens/maintenance_screen.dart';
import 'features/admin_tu/tu_dashboard.dart';
import 'features/admin_koordinator/koordinator_dashboard.dart';
import 'features/admin_koordinator/screens/koordinator_pengumuman_screen.dart';
import 'features/admin_koordinator/koordinator_rekap.dart';
import 'features/admin_koordinator/koordinator_tikrar.dart';
import 'features/murobbi/murobbi_dashboard.dart';
import 'features/pengampu/screens/pengampu_pesan_screen.dart';
import 'features/admin_kepsek/kepsek_dashboard.dart';
import 'features/wali/wali_dashboard.dart';
import 'features/pengampu/screens/pengampu_tikrar_screen.dart';
import 'features/pengampu/screens/pengampu_ukj_screen.dart';
import 'features/pengampu/screens/pengampu_uas_screen.dart';
import 'features/pengampu/screens/pengampu_akhlaq_screen.dart';
import 'features/admin_koordinator/screens/koordinator_ukj_screen.dart';
import 'features/admin_koordinator/screens/koordinator_syahrul_quran_screen.dart';
import 'features/admin_koordinator/screens/koordinator_pekan_murajaah_screen.dart';
import 'core/providers/auth_provider.dart' hide AuthState;
import 'features/shared/screens/profil_screen.dart';
import 'features/admin_koordinator/screens/koordinator_grade_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        final targetRoute = ref.read(logoutTargetProvider);
        navigatorKey.currentState?.pushNamedAndRemoveUntil(targetRoute, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI-Tahfiz Mobile',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        // Public (Unauthenticated)
        '/login': (context) => const LoginEmailScreen(),
        '/login/ortu': (context) => const LoginOrtuScreen(),
        '/maintenance': (context) => const MaintenanceScreen(),

        // Staff TU
        '/tu/akun': (context) => const RouteGuard(child: TuDashboard(initialIndex: 0)),
        '/tu/data/santri': (context) => const RouteGuard(child: TuDashboard(initialIndex: 1, initialTab: 0)),
        '/tu/data/halaqah': (context) => const RouteGuard(child: TuDashboard(initialIndex: 1, initialTab: 1)),
        '/tu/konfigurasi': (context) => const RouteGuard(child: TuDashboard(initialIndex: 2)),
        '/tu/sistem/audit': (context) => const RouteGuard(child: TuDashboard(initialIndex: 3, initialTab: 0)),
        '/tu/sistem/berita': (context) => const RouteGuard(child: TuDashboard(initialIndex: 3, initialTab: 1)),
        '/tu/profil': (context) => const RouteGuard(child: ProfilScreen()),

        // Koordinator
        '/koordinator/beranda': (context) => const RouteGuard(child: KoordinatorDashboard(initialIndex: 0)),
        '/koordinator/ukj': (context) => const RouteGuard(child: KoordinatorUkjScreen()),
        '/koordinator/kelola/syahrul-quran': (context) => const RouteGuard(child: KoordinatorSyahrulQuranScreen()),
        '/koordinator/kelola/pekan-murajaah': (context) => const RouteGuard(child: KoordinatorPekanMurajaahScreen()),
        '/koordinator/kelola/grade': (context) => const RouteGuard(child: KoordinatorGradeScreen()),
        '/koordinator/pengumuman': (context) => const RouteGuard(child: KoordinatorPengumumanScreen()),
        '/koordinator/rekap': (context) => const RouteGuard(child: KoordinatorRekap()),
        '/koordinator/pesan': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/pesan', isNested: true)),
        '/koordinator/halaqah': (context) => const RouteGuard(child: KoordinatorTikrar()),
        '/koordinator/profil': (context) => const RouteGuard(child: ProfilScreen()),

        // Pengampu (Murobbi)
        '/pengampu/beranda': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 0)),
        '/pengampu/setoran': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 1)),
        '/pengampu/absensi': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 2)),
        '/pengampu/lainnya': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 3)),
        '/pengampu/tikrar': (context) => const RouteGuard(child: PengampuTikrarScreen()),
        '/pengampu/ukj': (context) => const RouteGuard(child: PengampuUkjScreen()),
        '/pengampu/uas': (context) => const RouteGuard(child: PengampuUasScreen()),
        '/pengampu/akhlaq': (context) => const RouteGuard(child: PengampuAkhlaqScreen()),
        '/pengampu/pesan': (context) => const RouteGuard(child: PengampuPesanScreen()),
        '/pengampu/profil': (context) => const RouteGuard(child: ProfilScreen()),

        // Orang Tua (Wali)
        '/ortu/beranda': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 0)),
        '/ortu/manzil': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 1)),
        '/ortu/tikrar': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 2)),
        '/ortu/pesan': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 3)),
        '/ortu/profil': (context) => const RouteGuard(child: ProfilScreen()),

        // Kepala Sekolah
        '/kepsek/dashboard': (context) => const RouteGuard(child: KepsekDashboard(initialIndex: 0)),
        '/kepsek/rekap': (context) => const RouteGuard(child: KepsekDashboard(initialIndex: 1)),
        '/kepsek/profil': (context) => const RouteGuard(child: ProfilScreen()),
      },
    );
  }
}
