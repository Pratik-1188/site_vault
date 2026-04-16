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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Local Supabase Connection')),
        body: Center(
          child: StreamBuilder(
            // Just a test to see if we can reach the Auth module
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              return const Text('Connection Successful!');
            },
          ),
        ),
      ),
    );
  }
}
