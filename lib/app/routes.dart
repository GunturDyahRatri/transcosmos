import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/ui/bottom_navbar/bottom_navbar_page.dart';
import 'package:quran_audio/ui/home/detail_surah_page.dart';
import 'package:quran_audio/ui/home/home.dart';
import 'package:quran_audio/ui/splash/splash_page.dart';

class AppRoute {
  static final root = '/splashscreen';
  static final navBarHome = '/navBar';
  static final home = '/home';
  static final detailSurah = '/detailSurah';

  @override
  String toString() {
    return super.toString().replaceFirst('/', '');
  }
}

class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoute.root,
    routes: [
      GoRoute(
        name: AppRoute.root.toString(),
        path: AppRoute.root,
        builder: (_, state) => const SplashPage(),
      ),
      GoRoute(
        name: AppRoute.navBarHome.toString(),
        path: AppRoute.navBarHome,
        builder: (_, state) => const BottomNavBarPage(),
      ),
      GoRoute(
        name: AppRoute.home.toString(),
        path: AppRoute.home,
        builder: (_, state) => const SurahListPage(),
      ),
      GoRoute(
        name: AppRoute.detailSurah.toString(),
        path: AppRoute.detailSurah,
        builder: (_, state) {
          final data = state.extra as int;
          return SurahDetailPage(nomor: data);
        },
      ),
    ],
  );
}
