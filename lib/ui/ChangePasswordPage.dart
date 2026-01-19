import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../helpers/user_info.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  void _processChange() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showSnack("Konfirmasi password baru tidak cocok", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final result = await UserService().changePassword(
      UserInfo.username!, // Email user login
      _oldPassCtrl.text,
      _newPassCtrl.text,
    );

    setState(() => _isLoading = false);
    if (result['success']) {
      _showSnack(result['message'], Colors.green);
      Navigator.pop(context);
    } else {
      _showSnack(result['message'], Colors.red);
    }
  }

  void _showSnack(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: col));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ganti Password"), backgroundColor: const Color(0xFF192524), elevation: 0),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF192524), Color(0xFF3C5759)], begin: Alignment.topCenter),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField(_oldPassCtrl, "Password Lama", Icons.lock_outline),
              const SizedBox(height: 15),
              _buildField(_newPassCtrl, "Password Baru", Icons.lock_reset),
              const SizedBox(height: 15),
              _buildField(_confirmPassCtrl, "Konfirmasi Password Baru", Icons.check_circle_outline),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _isLoading ? null : _processChange,
                  child: _isLoading ? const CircularProgressIndicator() : const Text("Update Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        filled: true, fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}