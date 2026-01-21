import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import '../helpers/user_info.dart';

class CutiForm extends StatefulWidget {
  const CutiForm({super.key});

  @override
  State<CutiForm> createState() => _CutiFormState();
}

class _CutiFormState extends State<CutiForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaLengkapCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaLengkapCtrl.text = prefs.getString('name') ?? 'User';
    });
  }

  // --- REVISI: DIALOG DENGAN TEKS & TOMBOL DI TENGAH ---
  void _showMessageDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // Fixed: Remove isSuccess usage, use a neutral border color
          side: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
        
        title: Text(
          title, 
          textAlign: TextAlign.center, // Judul di tengah
          style: TextStyle(color: isSuccess ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message, 
          textAlign: TextAlign.center, // Pesan di tengah
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center( // Tombol di tengah
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
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
        title: const Text("Pengajuan Cuti", 
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
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send_rounded, size: 60, color: Color(0xFFD1EBDB)),
                          const SizedBox(height: 16),
                          const Text('Buat Pengajuan Baru', 
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),
                          
                          _buildModernField(_namaLengkapCtrl, "Nama Pegawai", Icons.person_outline, readOnly: true),
                          const SizedBox(height: 16),
                          _buildDateField(_tanggalMulaiCtrl, "Tanggal Mulai", Icons.calendar_today_outlined),
                          const SizedBox(height: 16),
                          _buildDateField(_tanggalSelesaiCtrl, "Tanggal Selesai", Icons.calendar_month_outlined),
                          const SizedBox(height: 16),
                          _buildModernField(_alasanCtrl, "Alasan Cuti", Icons.description_outlined, maxLines: 3),
                          const SizedBox(height: 32),
                          
                          _isSaving 
                            ? const CircularProgressIndicator(color: Color(0xFFD1EBDB)) 
                            : _buildSubmitButton(),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, 
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1EBDB), 
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isSaving = true);
            
            try {
              String tglMulaiStr = _tanggalMulaiCtrl.text.trim();
              String tglSelesaiStr = _tanggalSelesaiCtrl.text.trim();

              DateTime mulai = DateTime.parse(tglMulaiStr);
              DateTime selesai = DateTime.parse(tglSelesaiStr);
              DateTime sekarang = DateTime.now();
              DateTime hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

              if (mulai.difference(hariIni).inDays < 7) {
                _showMessageDialog("Peringatan", "Pengajuan cuti minimal 1 minggu sebelum hari-H");
                setState(() => _isSaving = false);
                return;
              }

              int durasi = selesai.difference(mulai).inDays + 1;
              if (durasi > 4) {
                _showMessageDialog("Peringatan", "Sekali pengajuan maksimal hanya boleh 4 hari");
                setState(() => _isSaving = false);
                return;
              }

              if (selesai.isBefore(mulai)) {
                _showMessageDialog("Kesalahan", "Tanggal selesai tidak boleh sebelum tanggal mulai");
                setState(() => _isSaving = false);
                return;
              }

              Cuti cuti = Cuti(
                ajukanCuti: UserInfo.username, 
                tanggalMulai: tglMulaiStr,
                tanggalSelesai: tglSelesaiStr,
                alasan: _alasanCtrl.text,
                status: 'Pending',
              );

              await CutiService().simpan(cuti).then((value) {
                // --- REVISI: DIALOG SUKSES DENGAN TEKS & TOMBOL DI TENGAH ---
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF192524),
                    shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // Fixed: Remove isSuccess usage, use a neutral border color
          side: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
                    title: const Center( // Judul/Icon di tengah
                      child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 50),
                    ),
                    content: const Text(
                      "Pengajuan Berhasil Dikirim!", 
                      textAlign: TextAlign.center, // Teks di tengah
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    actions: [
                      Center( // Tombol di tengah
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context, true);
                          },
                          child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                );
              });

            } catch (e) {
              _showMessageDialog("Error", "Terjadi kesalahan koneksi atau format data");
            } finally {
              if (mounted) setState(() => _isSaving = false);
            }
          }
        },
        child: const Text("KIRIM PENGAJUAN", 
          style: TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDateField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl, 
      readOnly: true, 
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context, 
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(), 
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFD1EBDB),
                  onPrimary: Color(0xFF192524),
                  surface: Color(0xFF203A43),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            ctrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          });
        }
      },
      validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
    );
  }

  Widget _buildModernField(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, 
      readOnly: readOnly, 
      maxLines: maxLines, 
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, 
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
      filled: true, 
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD1EBDB))),
    );
  }
}