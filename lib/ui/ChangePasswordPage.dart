import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../helpers/user_info.dart';
import '../widget/sidebar.dart';


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

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _processChange() async {
    // Validasi input kosong (Menggunakan Dialog)
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      _showAlertDialog("Peringatan", "Harap isi semua kolom password.", Colors.orangeAccent);
      return;
    }

    // Validasi kecocokan password (Menggunakan Dialog)
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showAlertDialog("Kesalahan", "Konfirmasi password baru tidak cocok.", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    final result = await UserService().changePassword(
      UserInfo.username!, 
      _oldPassCtrl.text,
      _newPassCtrl.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showAlertDialog("Gagal", result['message'], Colors.redAccent);
    }
  }

  // --- DIALOG UNTUK PESAN SUKSES ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
        title: const Center(
          child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Berhasil!", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text(
              "Password Anda telah berhasil diperbarui. Gunakan password baru Anda untuk masuk kembali.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG UNTUK PERINGATAN / ERROR ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Ganti Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,)),
        backgroundColor: const Color(0xFF192524),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildField(_oldPassCtrl, "Password Lama", Icons.lock_outline, _obscureOld, 
                () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 15),
              _buildField(_newPassCtrl, "Password Baru", Icons.lock_reset, _obscureNew, 
                () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 15),
              _buildField(_confirmPassCtrl, "Konfirmasi Password Baru", Icons.check_circle_outline, _obscureConfirm, 
                () => setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _processChange,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("UPDATE PASSWORD", 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.tealAccent),
        ),
      ),
    );
  }
}