import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/feature/site/screen/site_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using the variables from our JSON file
  await Supabase.initialize(url: Env.url, anonKey: Env.anonKey);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLocal =
        Env.url.contains('localhost') || Env.url.contains('127.0.0.1');

    return MaterialApp(
      debugShowCheckedModeBanner: isLocal,
      home: const SitesScreen(), // 👈 show sites screen directly
    );
  }
}
