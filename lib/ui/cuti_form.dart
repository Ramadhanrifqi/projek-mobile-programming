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
  List<Cuti> _existingCuti = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadExistingData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaLengkapCtrl.text = prefs.getString('name') ?? 'User';
    });
  }

  Future<void> _loadExistingData() async {
    final data = await CutiService().listData();
    setState(() {
      _existingCuti = data.where((c) => 
        c.ajukanCuti?.toLowerCase() == UserInfo.username?.toLowerCase()
      ).toList();
    });
  }

  // --- REVISI: DIALOG YANG MENUNGGU KLIK OK UNTUK PINDAH HALAMAN ---
  void _showMessageDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib klik OK, tidak bisa asal klik luar
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
            width: 2,
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline, 
                color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message, 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70 ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // 1. Tutup Dialog-nya dulu
                Navigator.pop(ctx); 
                
                // 2. Jika ini dialog sukses, barulah tutup halaman Form-nya
                if (isSuccess) {
                  Navigator.pop(context, true); 
                }
              },
              child: Text(
                "OK", 
                style: TextStyle(
                  color: isSuccess ? const Color(0xFFD1EBDB) : Colors.redAccent, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                ),
              ),
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
        elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
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
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1EBDB), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isSaving = true);
            
            try {
              // 1. Validasi Pending
              int pendingCount = _existingCuti.where((c) => c.status?.toLowerCase() == 'pending').length;
              if (pendingCount >= 2) {
                _showMessageDialog("Peringatan", "Anda memiliki 2 pengajuan pending. Silahkan tunggu konfirmasi admin.");
                setState(() => _isSaving = false);
                return;
              }

              String tglMulaiStr = _tanggalMulaiCtrl.text.trim();
              String tglSelesaiStr = _tanggalSelesaiCtrl.text.trim();

              // 2. Cek Bentrok
              bool isBentrok = _existingCuti.any((c) => 
                c.tanggalMulai == tglMulaiStr || c.tanggalSelesai == tglSelesaiStr
              );
              if (isBentrok) {
                _showMessageDialog("Gagal", "Anda sudah memiliki pengajuan di tanggal tersebut.");
                setState(() => _isSaving = false);
                return;
              }

              DateTime mulai = DateTime.parse(tglMulaiStr);
              DateTime selesai = DateTime.parse(tglSelesaiStr);
              DateTime hariIni = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

              // 3. Validasi H-7
              if (mulai.difference(hariIni).inDays < 7) {
                _showMessageDialog("Peringatan", "Pengajuan cuti minimal harus dilakukan 7 hari sebelum tanggal mulai.");
                setState(() => _isSaving = false);
                return;
              }

              // 4. Validasi 4 Hari
              int durasi = selesai.difference(mulai).inDays + 1;
              if (durasi > 4) {
                _showMessageDialog("Peringatan", "Sekali pengajuan maksimal hanya boleh 4 hari.");
                setState(() => _isSaving = false);
                return;
              }

              if (selesai.isBefore(mulai)) {
                _showMessageDialog("Kesalahan", "Tanggal selesai tidak boleh sebelum tanggal mulai");
                setState(() => _isSaving = false);
                return;
              }

              Map<String, dynamic> data = {
                "nama": UserInfo.username, 
                "tanggalMulai": tglMulaiStr,
                "tanggalSelesai": tglSelesaiStr,
                "alasan": _alasanCtrl.text,
                "Status": 'Pending',
              };

              final result = await CutiService().simpan(data);

              if (result['success']) {
                if (!mounted) return;
                // Panggil dialog sukses. Navigasi pop sudah ditangani di dalam fungsi ini saat klik OK.
                _showMessageDialog("Berhasil", "Pengajuan Berhasil Dikirim!", isSuccess: true);
              } else {
                _showMessageDialog("Gagal Mengajukan", result['message']);
              }
            } catch (e) {
              _showMessageDialog("Error", "Terjadi kesalahan sistem.");
            } finally {
              if (mounted) setState(() => _isSaving = false);
            }
          }
        },
        child: const Text("KIRIM PENGAJUAN", style: TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDateField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl, readOnly: true, style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context, initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(), lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(primary: Color(0xFFD1EBDB), onPrimary: Color(0xFF192524), surface: Color(0xFF203A43)),
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
      controller: ctrl, readOnly: readOnly, maxLines: maxLines, style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
      filled: true, fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD1EBDB))),
    );
  }
}