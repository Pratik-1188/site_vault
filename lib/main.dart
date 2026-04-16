import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using the variables from our JSON file
  await Supabase.initialize(url: Env.url, anonKey: Env.anonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLocal =
        Env.url.contains('localhost') || Env.url.contains('127.0.0.1');

    return MaterialApp(
      debugShowCheckedModeBanner: isLocal,
      home: Scaffold(
        appBar: AppBar(title: const Text('My App')),
        body: Center(child: Text('Connection Successful!')),
      ),
    );
  }
}
