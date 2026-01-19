import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini untuk FilteringTextInputFormatter
import 'package:intl/intl.dart';
import '../model/user.dart';
import '../service/user_service.dart';

class TambahKaryawanPage extends StatefulWidget {
  const TambahKaryawanPage({super.key});

  @override
  State<TambahKaryawanPage> createState() => _TambahKaryawanPageState();
}

class _TambahKaryawanPageState extends State<TambahKaryawanPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  
  // Controller Baru & Update
  final _addressCtrl = TextEditingController();
  final _joinDateCtrl = TextEditingController();
  final _awardsCtrl = TextEditingController();
  final _jobDescCtrl = TextEditingController(); // Pengganti dropdown jenis pekerjaan

  String? _selectedDepartment;
  String? _selectedLevel;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _joinDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tambah Profil Lengkap", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1EBDB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.person, "Informasi Pribadi"),
                        _buildModernField(_nameCtrl, "Nama Lengkap", Icons.badge_outlined),
                        _buildModernField(_emailCtrl, "Email", Icons.email_outlined),
                        
                        // Validasi Password Minimal 8 Karakter
                        _buildPasswordField(),
                        
                        // Input Nomor Telepon (Hanya Angka)
                        _buildPhoneField(),

                        _buildModernField(_addressCtrl, "Alamat Domisili", Icons.home_outlined, maxLines: 2),
                        
                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.work_outline, "Detail Pekerjaan"),
                        
                        // Deskripsi Pekerjaan (Bukan Dropdown)
                        _buildModernField(_jobDescCtrl, "Deskripsi Pekerjaan", Icons.assignment_outlined, maxLines: 2),

                        _buildModernDropdown(
                          label: "Departemen",
                          icon: Icons.account_tree_outlined,
                          value: _selectedDepartment,
                          items: ["Operator", "Gudang", "HR", "Produksi"],
                          onChanged: (v) => setState(() => _selectedDepartment = v),
                        ),

                        // Level Terbatas (Junior, Senior, Lead)
                        _buildModernDropdown(
                          label: "Level",
                          icon: Icons.trending_up,
                          value: _selectedLevel,
                          items: ["Junior", "Senior", "Lead"],
                          onChanged: (v) => setState(() => _selectedLevel = v),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: _joinDateCtrl,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Tanggal Masuk", Icons.calendar_today).copyWith(
                              suffixIcon: const Icon(Icons.date_range, color: Color(0xFFD1EBDB)),
                            ),
                            onTap: () => _selectDate(context),
                            validator: (v) => v!.isEmpty ? "Tanggal wajib diisi" : null,
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.emoji_events_outlined, "Pencapaian & Skill"),
                        _buildModernField(_educationCtrl, "Pendidikan Terakhir", Icons.school),
                        _buildModernField(_skillsCtrl, "Keahlian", Icons.psychology),
                        _buildModernField(_awardsCtrl, "Penghargaan", Icons.star_border_purple500),
                        _buildModernField(_bioCtrl, "Bio Singkat", Icons.description, maxLines: 3),
                        
                        const SizedBox(height: 30),
                        _buildSubmitButton(),
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

  // Widget khusus Password dengan validasi 8 karakter
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _passwordCtrl,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration("Password", Icons.lock_outline),
        validator: (v) {
          if (v!.isEmpty) return "Password wajib diisi";
          if (v.length < 8) return "Password minimal 8 karakter";
          return null;
        },
      ),
    );
  }

  // Widget khusus Telepon (Hanya Angka)
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration("Nomor Telepon", Icons.phone_android),
        validator: (v) => v!.isEmpty ? "Nomor telepon wajib diisi" : null,
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModernField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }

  Widget _buildModernDropdown({required String label, required IconData icon, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF3C5759),
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "$label wajib dipilih" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD1EBDB))),
      errorStyle: const TextStyle(color: Colors.orangeAccent),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final user = User(
              name: _nameCtrl.text,
              email: _emailCtrl.text,
              password: _passwordCtrl.text,
              role: 'user',
              phone: _phoneCtrl.text,
              department: _selectedDepartment,
              level: _selectedLevel,
              education: _educationCtrl.text,
              skills: _skillsCtrl.text,
              bio: _bioCtrl.text,
              alamat: _addressCtrl.text,
              joinDate: _joinDateCtrl.text,
              jobType: _jobDescCtrl.text, // Menyimpan deskripsi pekerjaan
              awards: _awardsCtrl.text,
            );
            
            bool success = await UserService().tambahUser(user);
            if (success) {
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Karyawan Berhasil Disimpan")));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1EBDB),
          foregroundColor: const Color(0xFF192524),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("SIMPAN DATA LENGKAP", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}