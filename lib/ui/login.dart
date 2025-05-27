import 'package:flutter/material.dart';
import '../service/login_service.dart';
import '../model/user.dart';
import '../helpers/user_info.dart';
import 'beranda.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(String username, String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('role', role);
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final user = await LoginService().login(
        _usernameCtrl.text,
        _passwordCtrl.text,
      );

      if (user != null) {
        UserInfo.setUser(user);
        if (!mounted) return;
        await saveUserInfo(user.username, user.role);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Beranda(
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal!')),
        );
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3C5759), 
            Color(0xFF192524),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              color: const Color(0xFFD0D5CE).withOpacity(0.25), // soft dengan transparansi
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.4), // border halus
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Image.asset(
                          'assets/images/images/Logo.naga.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "PT. NAGA HYTAM",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sistem Manajemen Perusahaan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFF5F5F5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 16),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: const Icon(Icons.person, color: Color(0xFF3C5759)),
                                labelStyle: const TextStyle(color: Color(0xFF3C5759)),
                                filled: true,
                                fillColor: const Color(0xFFD1EBDB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF3C5759)),
                                labelStyle: const TextStyle(color: Color(0xFF3C5759)),
                                filled: true,
                                fillColor: const Color(0xFFD1EBDB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3C5759),
                                  foregroundColor: Colors.white,
                                  
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, // border halus
                                        width: 1.5,
                                      ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Masuk"),
                              ),
                            ),
                          ],
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
  );
}

}
