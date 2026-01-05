import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  // --- LOGIKA LOGIN TETAP SAMA (ORIGINAL KAMU) ---
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // 1. SPACER ATAS (Dorong konten ke tengah)
              const Spacer(),

              // 2. KONTEN UTAMA (Logo & Tombol)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon Besar dengan Background Kuning Tipis
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined, // Icon original kamu
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul
                  const Text(
                    'Notely',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    'Catat Apa Aja Disini.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 48),

                  // Tombol Login
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.amber)
                      : SizedBox(
                          width: double.infinity, // Tombol selebar layar
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _googleSignIn,
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: const Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                ],
              ),

              // 3. SPACER BAWAH (Dorong footer ke dasar layar)
              const Spacer(),

              // 4. FOOTER (By Firly Fahriza)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crafted with ❤️ by',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Firly Fahriza',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '© 2026 All Rights Reserved',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
