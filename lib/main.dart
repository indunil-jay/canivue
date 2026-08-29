import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/routing/app_router.dart';
import 'package:canivue/core/theme/app_theme.dart';

void main() {
  runApp(const CanivueApp());
}

/// Root widget. Owns the [ProviderScope] so `CanivueApp()` is a complete,
/// self-contained app — usable as-is from `main()` or from a widget test
/// without the caller having to remember to wrap it.
class CanivueApp extends StatelessWidget {
  const CanivueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _CanivueAppView());
  }
}

class _CanivueAppView extends ConsumerWidget {
  const _CanivueAppView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'Canivue',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
