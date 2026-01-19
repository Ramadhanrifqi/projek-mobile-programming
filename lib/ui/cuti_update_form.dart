import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';

class CutiUpdateFormPage extends StatefulWidget {
  final Cuti cuti;
  final String namaPengaju;

  const CutiUpdateFormPage({super.key, required this.cuti, required this.namaPengaju});

  @override
  State<CutiUpdateFormPage> createState() => _CutiUpdateFormPageState();
}

class _CutiUpdateFormPageState extends State<CutiUpdateFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _ajukanCutiCtrl = TextEditingController();
  final _tanggalMulaiCtrl = TextEditingController();
  final _tanggalSelesaiCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi data awal dari widget yang dikirim
    _ajukanCutiCtrl.text = widget.namaPengaju;
    _tanggalMulaiCtrl.text = widget.cuti.tanggalMulai ?? '';
    _tanggalSelesaiCtrl.text = widget.cuti.tanggalSelesai ?? '';
    _alasanCtrl.text = widget.cuti.alasan ?? '';
    _statusCtrl.text = widget.cuti.status ?? 'Pending';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Update Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          const Icon(Icons.edit_calendar_rounded, size: 60, color: Color(0xFFD1EBDB)),
                          const SizedBox(height: 16),
                          const Text('Proses Pengajuan Cuti', 
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),
                          
                          _buildReadOnlyField(_ajukanCutiCtrl, "Nama Pengaju", Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildReadOnlyField(_tanggalMulaiCtrl, "Tanggal Mulai", Icons.calendar_today),
                          const SizedBox(height: 16),
                          _buildReadOnlyField(_tanggalSelesaiCtrl, "Tanggal Selesai", Icons.calendar_month),
                          const SizedBox(height: 16),
                          _buildReadOnlyField(_alasanCtrl, "Alasan", Icons.notes, maxLines: 2),
                          const SizedBox(height: 16),
                          
                          // Dropdown untuk mengubah status
                          _buildStatusDropdown(),
                          
                          const SizedBox(height: 32),
                          _isLoading 
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

  Widget _buildReadOnlyField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white70),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _statusCtrl.text,
      dropdownColor: const Color(0xFF203A43),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: _inputDecoration("Keputusan Admin", Icons.rule_rounded),
      items: ['Pending', 'Disetujui', 'Ditolak'].map((status) {
        return DropdownMenuItem(value: status, child: Text(status));
      }).toList(),
      onChanged: (value) => setState(() => _statusCtrl.text = value!),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1EBDB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            // Membuat objek cuti dengan status yang baru
            Cuti cutiBaru = Cuti(
              id: widget.cuti.id,
              ajukanCuti: widget.cuti.ajukanCuti,
              tanggalMulai: _tanggalMulaiCtrl.text,
              tanggalSelesai: _tanggalSelesaiCtrl.text,
              alasan: _alasanCtrl.text,
              status: _statusCtrl.text,
            );

            // Memanggil service ubah (Pastikan id tidak null dengan tanda !)
            await CutiService().ubah(cutiBaru, widget.cuti.id!).then((value) {
              _showSnackBar("Status berhasil diperbarui", Colors.green);
              Navigator.pop(context, true); // True untuk sinyal refresh data
            });
          } catch (e) {
            _showSnackBar("Gagal memperbarui: $e", Colors.redAccent);
          } finally {
            setState(() => _isLoading = false);
          }
        },
        child: const Text("SIMPAN PERUBAHAN", 
          style: TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold)),
      ),
    );
  }
}