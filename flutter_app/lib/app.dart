import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/home_page.dart';
import 'pages/write_page.dart';
import 'pages/ai_result_page.dart';
import 'pages/drift_page.dart';
import 'pages/drift_detail_page.dart';
import 'pages/mine_page.dart';
import 'pages/login_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/drift', builder: (_, __) => const DriftPage()),
          GoRoute(path: '/mine', builder: (_, __) => const MinePage()),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/write',
        builder: (_, __) => const WritePage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai-result/:diaryId',
        builder: (_, state) => AiResultPage(
          diaryId: int.parse(state.pathParameters['diaryId']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/drift-detail/:bottleId',
        builder: (_, state) => DriftDetailPage(
          bottleId: int.parse(state.pathParameters['bottleId']!),
        ),
      ),
    ],
  );
});

class DriftDiaryApp extends ConsumerWidget {
  const DriftDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDayMode = ref.watch(isDayModeProvider);
    final authStatus = ref.watch(authProvider);

    if (authStatus == AuthStatus.loading) {
      return MaterialApp(
        theme: isDayMode ? AppTheme.day : AppTheme.night,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (authStatus == AuthStatus.unauthenticated) {
      return MaterialApp(
        title: 'AI日记漂流瓶',
        theme: isDayMode ? AppTheme.day : AppTheme.night,
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      );
    }

    return MaterialApp.router(
      title: 'AI日记漂流瓶',
      theme: isDayMode ? AppTheme.day : AppTheme.night,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    int currentIndex = 0;
    if (location.startsWith('/drift')) currentIndex = 1;
    if (location.startsWith('/mine')) currentIndex = 2;

    return Container(
      decoration: BoxDecoration(
        color: isDayMode
            ? AppTheme.dayIvory.withOpacity(0.92)
            : AppTheme.nightBg.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDayMode
                ? Colors.black.withOpacity(0.06)
                : Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: isDayMode
            ? AppTheme.dayAccent.withOpacity(0.08)
            : Colors.white.withOpacity(0.08),
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/drift');
            case 2:
              context.go('/mine');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.sailing_outlined), selectedIcon: Icon(Icons.sailing), label: '漂流'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
