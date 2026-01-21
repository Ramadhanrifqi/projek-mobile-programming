import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
       _skillsCtrl, _bioCtrl, _addressCtrl, _joinDateCtrl, _awardsCtrl, _jobDescCtrl;

  String? _selectedDepartment;
  String? _selectedLevel;
  bool _isLoading = false;

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
    _jobDescCtrl = TextEditingController(text: widget.user.jobType);

    _selectedDepartment = widget.user.department;
    _selectedLevel = widget.user.level;
  }

  // --- REVISI: DATE PICKER TEMA GELAP ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD1EBDB),
              onPrimary: Color(0xFF192524),
              surface: Color(0xFF192524),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF192524),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _joinDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- REVISI: DIALOG DENGAN BORDER & RATA TENGAH ---
  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSuccess ? Colors.greenAccent : Colors.redAccent, width: 2), // Tambah Border
        ),
        title: Center(
          child: Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: isSuccess ? Colors.greenAccent : Colors.redAccent,
            size: 50,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (isSuccess) Navigator.pop(context, true);
              },
              child: const Text("OK", 
                style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
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
                    color: Colors.white.withOpacity(0.08),
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
                        _buildPhoneField(),
                        _buildModernField(_addressCtrl, "Alamat", Icons.home_outlined, maxLines: 2),

                        const SizedBox(height: 20),
                        _buildSectionTitle(Icons.work_outline, "Pekerjaan"),
                        _buildModernField(_jobDescCtrl, "Deskripsi Pekerjaan", Icons.assignment_outlined, maxLines: 2),
                        _buildModernDropdown("Departemen", Icons.account_tree_outlined, _selectedDepartment, 
                            ["Operator", "Gudang", "HR", "Produksi"], (v) => setState(() => _selectedDepartment = v)),
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
                        _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                          : _buildSaveButton(),
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
        value: items.contains(value) ? value : null,
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
        onPressed: _isLoading ? null : () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            final updatedUser = User(
              id: widget.user.id,
              name: _nameCtrl.text,
              email: _emailCtrl.text,
              password: widget.user.password, // Menggunakan password lama
              role: widget.user.role,
              phone: _phoneCtrl.text,
              department: _selectedDepartment,
              level: _selectedLevel,
              education: _educationCtrl.text,
              skills: _skillsCtrl.text,
              bio: _bioCtrl.text,
              alamat: _addressCtrl.text,
              joinDate: _joinDateCtrl.text,
              jobType: _jobDescCtrl.text,
              awards: _awardsCtrl.text,
            );

            try {
              bool success = await UserService().updateUser(updatedUser);
              setState(() => _isLoading = false);
              if (success) {
                _showResultDialog("Berhasil", "Data Karyawan Telah Diperbarui", true);
              } else {
                _showResultDialog("Gagal", "Tidak dapat menyimpan perubahan", false);
              }
            } catch (e) {
              setState(() => _isLoading = false);
              _showResultDialog("Error", e.toString(), false);
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