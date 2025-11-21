// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/lead_list_screen.dart';
import 'screens/add_lead_screen.dart';
import 'screens/lead_detail_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LeadListScreen()),
    GoRoute(path: '/add', builder: (context, state) => const AddLeadScreen()),
    GoRoute(path: '/detail/:id', builder: (context, state) {
      final id = int.parse(state.pathParameters['id']!);
      return LeadDetailScreen(leadId: id);
    }),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}