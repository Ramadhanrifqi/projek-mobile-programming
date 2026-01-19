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

  void _showSnackBar(String message, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isSaving = true);
            
            try {
              // Menghilangkan jam agar formatnya murni YYYY-MM-DD
              String tglMulaiStr = _tanggalMulaiCtrl.text.trim();
              String tglSelesaiStr = _tanggalSelesaiCtrl.text.trim();

              DateTime mulai = DateTime.parse(tglMulaiStr);
              DateTime selesai = DateTime.parse(tglSelesaiStr);
              DateTime sekarang = DateTime.now();
              DateTime hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

              // Validasi Bisnis
              if (mulai.difference(hariIni).inDays < 7) {
                _showSnackBar("Pengajuan cuti minimal 1 minggu sebelum hari-H");
                setState(() => _isSaving = false);
                return;
              }

              int durasi = selesai.difference(mulai).inDays + 1;
              if (durasi > 4) {
                _showSnackBar("Sekali pengajuan maksimal hanya boleh 4 hari");
                setState(() => _isSaving = false);
                return;
              }

              if (selesai.isBefore(mulai)) {
                _showSnackBar("Tanggal selesai tidak boleh sebelum tanggal mulai");
                setState(() => _isSaving = false);
                return;
              }

              // Mapping data ke model Cuti
              Cuti cuti = Cuti(
                ajukanCuti: UserInfo.username, // Mengirim email login ke Laravel
                tanggalMulai: tglMulaiStr,
                tanggalSelesai: tglSelesaiStr,
                alasan: _alasanCtrl.text,
                status: 'Pending',
              );

              // Eksekusi Simpan
              await CutiService().simpan(cuti).then((value) {
                _showSnackBar("Pengajuan Berhasil Dikirim", color: Colors.green);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) Navigator.pop(context, true);
                });
              });

            } catch (e) {
              debugPrint("ERROR_SIMPAN: $e");
              _showSnackBar("Terjadi kesalahan koneksi atau format data");
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
            // Format YYYY-MM-DD
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
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }
}