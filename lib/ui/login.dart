import 'package:flutter/material.dart';
import '../service/login_service.dart';
import '../model/user.dart';
import '../helpers/user_info.dart';
import 'beranda.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Beranda()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const Text(
  "Sistem Manajemen Perusahaan",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
),

                const SizedBox(height: 8),
                const Text(
                  "PT. NAGA HYTAM",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Username wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Password wajib diisi' : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
    );
  }
}
