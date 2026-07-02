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
import 'features/admin_koordinator/koordinator_pengumuman.dart';
import 'features/admin_koordinator/koordinator_rekap.dart';
import 'features/admin_koordinator/koordinator_tikrar.dart';
import 'features/murobbi/murobbi_dashboard.dart';
import 'features/murobbi/murobbi_jurnal.dart';
import 'features/murobbi/murobbi_chat_list.dart';
import 'features/admin_kepsek/kepsek_dashboard.dart';
import 'features/wali/wali_dashboard.dart';
import 'features/murobbi/murobbi_tikrar.dart';

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
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
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
        '/tu/data/santri': (context) => const RouteGuard(child: TuDashboard(initialIndex: 1)),
        '/tu/konfigurasi': (context) => const RouteGuard(child: TuDashboard(initialIndex: 2)),
        '/tu/sistem/audit': (context) => const RouteGuard(child: TuDashboard(initialIndex: 3)),
        '/tu/data/halaqah': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/tu/data/halaqah', isNested: true)),
        '/tu/sistem/berita': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/tu/sistem/berita', isNested: true)),
        '/tu/profil': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/tu/profil', isNested: true)),

        // Koordinator
        '/koordinator/beranda': (context) => const RouteGuard(child: KoordinatorDashboard(initialIndex: 0)),
        '/koordinator/ukj': (context) => const RouteGuard(child: KoordinatorDashboard(initialIndex: 1)),
        '/koordinator/kelola/syahrul-quran': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/kelola/syahrul-quran', isNested: true)),
        '/koordinator/kelola/pekan-murajaah': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/kelola/pekan-murajaah', isNested: true)),
        '/koordinator/kelola/grade': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/kelola/grade', isNested: true)),
        '/koordinator/pengumuman': (context) => const RouteGuard(child: KoordinatorPengumuman()),
        '/koordinator/rekap': (context) => const RouteGuard(child: KoordinatorRekap()),
        '/koordinator/pesan': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/pesan', isNested: true)),
        '/koordinator/halaqah': (context) => const RouteGuard(child: KoordinatorTikrar()),
        '/koordinator/profil': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/koordinator/profil', isNested: true)),

        // Pengampu (Murobbi)
        '/pengampu/beranda': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 0)),
        '/pengampu/setoran': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 1)),
        '/pengampu/absensi': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 2)),
        '/pengampu/lainnya': (context) => const RouteGuard(child: MurobbiDashboard(initialIndex: 3)),
        '/pengampu/tikrar': (context) => const RouteGuard(child: MurobbiTikrar()),
        '/pengampu/ukj': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/pengampu/ukj', isNested: true)),
        '/pengampu/uas': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/pengampu/uas', isNested: true)),
        '/pengampu/akhlaq': (context) => const RouteGuard(child: MurobbiJurnal()),
        '/pengampu/pesan': (context) => const RouteGuard(child: MurobbiChatList()),
        '/pengampu/profil': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/pengampu/profil', isNested: true)),

        // Orang Tua (Wali)
        '/ortu/beranda': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 0)),
        '/ortu/manzil': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 1)),
        '/ortu/tikrar': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 2)),
        '/ortu/pesan': (context) => const RouteGuard(child: WaliDashboard(initialIndex: 3)),
        '/ortu/profil': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/ortu/profil', isNested: true)),

        // Kepala Sekolah
        '/kepsek/dashboard': (context) => const RouteGuard(child: KepsekDashboard(initialIndex: 0)),
        '/kepsek/rekap': (context) => const RouteGuard(child: KepsekDashboard(initialIndex: 1)),
        '/kepsek/profil': (context) => const RouteGuard(child: PlaceholderScreen(routeName: '/kepsek/profil', isNested: true)),
      },
    );
  }
}
