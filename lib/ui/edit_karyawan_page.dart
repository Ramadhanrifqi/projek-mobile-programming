import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Penting untuk FilteringTextInputFormatter
import 'package:intl/intl.dart';
import '../model/user.dart';
import '../service/user_service.dart';

class EditKaryawanPage extends StatefulWidget {
  final User user;
  const EditKaryawanPage({super.key, required this.user});

  @override
  State<EditKaryawanPage> createState() => _EditKaryawanPageState();
}

class _EditKaryawanPageState extends State<EditKaryawanPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl, _emailCtrl, _phoneCtrl, _educationCtrl, 
       _skillsCtrl, _bioCtrl, _addressCtrl, _joinDateCtrl, _awardsCtrl, 
       _newPasswordCtrl, _jobDescCtrl; // Ditambahkan _jobDescCtrl

  String? _selectedDepartment;
  String? _selectedLevel;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _educationCtrl = TextEditingController(text: widget.user.education);
    _skillsCtrl = TextEditingController(text: widget.user.skills);
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _addressCtrl = TextEditingController(text: widget.user.alamat);
    _joinDateCtrl = TextEditingController(text: widget.user.joinDate);
    _awardsCtrl = TextEditingController(text: widget.user.awards);
    _jobDescCtrl = TextEditingController(text: widget.user.jobType); // Inisialisasi deskripsi
    _newPasswordCtrl = TextEditingController();

    _selectedDepartment = widget.user.department;
    _selectedLevel = widget.user.level;
  }

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
        title: const Text("Edit Profil Karyawan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                        
                        // Validasi Telepon (Hanya Angka)
                        _buildPhoneField(),

                        _buildModernField(_addressCtrl, "Alamat", Icons.home_outlined, maxLines: 2),

                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.security, "Keamanan (Opsional)"),
                        
                        // Validasi Password (Minimal 8 Karakter jika diisi)
                        _buildPasswordField(),

                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.work_outline, "Pekerjaan"),
                        
                        // Deskripsi Pekerjaan (Bukan Dropdown)
                        _buildModernField(_jobDescCtrl, "Deskripsi Pekerjaan", Icons.assignment_outlined, maxLines: 2),

                        _buildModernDropdown("Departemen", Icons.account_tree_outlined, _selectedDepartment, 
                            ["Operator", "Gudang", "HR", "Produksi"], (v) => setState(() => _selectedDepartment = v)),
                        
                        // Level Terbatas
                        _buildModernDropdown("Level", Icons.trending_up, _selectedLevel, 
                            ["Junior", "Senior", "Lead"], (v) => setState(() => _selectedLevel = v)),
                        
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: _joinDateCtrl,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Tanggal Masuk", Icons.calendar_today),
                            onTap: () => _selectDate(context),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.emoji_events_outlined, "Kualifikasi & Bio"),
                        _buildModernField(_educationCtrl, "Pendidikan", Icons.school_outlined),
                        _buildModernField(_skillsCtrl, "Keahlian", Icons.psychology_outlined),
                        _buildModernField(_awardsCtrl, "Penghargaan", Icons.star_border),
                        _buildModernField(_bioCtrl, "Bio", Icons.description_outlined, maxLines: 3),

                        const SizedBox(height: 30),
                        _buildSaveButton(),
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

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _newPasswordCtrl,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration("Password Baru", Icons.lock_reset_outlined).copyWith(
          helperText: "Kosongkan jika tidak ingin mengganti",
          helperStyle: const TextStyle(color: Colors.white54, fontSize: 11),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD1EBDB)),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (v) {
          if (v != null && v.isNotEmpty && v.length < 8) {
            return "Password minimal 8 karakter";
          }
          return null;
        },
      ),
    );
  }

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

  Widget _buildModernDropdown(String label, IconData icon, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null, // Mencegah error jika data lama tidak ada di list baru
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
      filled: true, fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD1EBDB))),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final updatedUser = User(
              id: widget.user.id,
              name: _nameCtrl.text,
              email: _emailCtrl.text,
              password: _newPasswordCtrl.text.isNotEmpty ? _newPasswordCtrl.text : widget.user.password, 
              role: widget.user.role,
              phone: _phoneCtrl.text,
              department: _selectedDepartment,
              level: _selectedLevel,
              education: _educationCtrl.text,
              skills: _skillsCtrl.text,
              bio: _bioCtrl.text,
              alamat: _addressCtrl.text,
              joinDate: _joinDateCtrl.text,
              jobType: _jobDescCtrl.text, // Mengambil data dari controller teks
              awards: _awardsCtrl.text,
            );

            bool success = await UserService().updateUser(updatedUser);
            if (success) {
              if (!mounted) return;
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perubahan Berhasil Disimpan")));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1EBDB), foregroundColor: const Color(0xFF192524),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}