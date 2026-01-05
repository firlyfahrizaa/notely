import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Supabase 
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', // Ganti URL Project Setting
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '', // Ganti Anon Public Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan UAS',
      theme: ThemeData(
        primarySwatch: Colors.amber, // Warna mirip Google Keep
        useMaterial3: true,
      ),
      // 2. Cek status login
      // Jika user sudah login -> Masuk Home. Jika belum -> Masuk Login.
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginPage()
          : const HomePage(),
    );
  }
}