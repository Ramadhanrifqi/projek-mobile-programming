import 'dart:ui';
import 'package:flutter/material.dart';
import '../service/login_service.dart';
import '../helpers/user_info.dart';
import 'beranda.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  // --- FUNGSI DIALOG PERINGATAN / ERROR (Rata Tengah dengan Border) ---
  void _showAlertDialog(String title, String message, Color borderColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 2),
        ),
        title: Center(
          child: Icon(
            title == "Peringatan" ? Icons.warning_amber_rounded : Icons.error_outline,
            color: borderColor,
            size: 50,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, 
              style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveUserInfo(String name, String role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);      
    await prefs.setString('role', role);      
    await prefs.setString('email', email);    
  }

  void _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showAlertDialog("Peringatan", "Email dan Password wajib diisi.", Colors.orangeAccent);
      return;
    }

    // Menampilkan loading indikator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB))),
    );

    try {
      // 1. Panggil Service Login (Mendapatkan data response lengkap)
      final response = await LoginService().login(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      // 2. Cek apakah login berhasil berdasarkan struktur data API Anda
      if (response != null && response['user'] != null) {
        // Ambil data user dari objek response
        final userData = response['user'];
        final token = response['token']; // Pastikan key-nya 'token' sesuai API Laravel

        // 3. Set data ke UserInfo (User Model & Token String)
        UserInfo.setUser(userData, token); 
        
        // 4. Simpan ke Local Storage (SharedPreferences)
        await saveUserInfo(userData.name ?? '', userData.role ?? '', userData.email ?? '');
        
        // 5. Navigasi ke Beranda
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Beranda()),
        );
      } else {
        _showAlertDialog("Gagal Masuk", "Email atau Password salah.", Colors.redAccent);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup loading jika error
      _showAlertDialog("Error", "Terjadi kesalahan: $e", Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3C5759), Color(0xFF192524)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset('assets/images/Logo.naga.png', height: 100),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Selamat Datang",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                          ),
                          const Text(
                            "Silakan masuk ke akun Anda",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(
                            controller: _emailCtrl,
                            label: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordCtrl,
                            label: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _isObscure,
                            toggleVisibility: () => setState(() => _isObscure = !_isObscure),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD1EBDB),
                                foregroundColor: const Color(0xFF192524),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD1EBDB)),
        ),
      ),
    );
  }
}