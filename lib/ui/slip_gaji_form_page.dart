import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../model/slip_gaji.dart';
import '../model/user.dart';
import '../service/slip_gaji_service.dart';
import '../service/user_service.dart';

class SlipGajiFormPage extends StatefulWidget {
  final SlipGaji? slip;
  final User? targetUser;

  const SlipGajiFormPage({super.key, this.slip, this.targetUser});

  @override
  State<SlipGajiFormPage> createState() => _SlipGajiFormPageState();
}

class _SlipGajiFormPageState extends State<SlipGajiFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  final _gajiPokokCtrl = TextEditingController();
  final _tunjanganCtrl = TextEditingController();
  final _potonganCtrl = TextEditingController();
  final _totalGajiCtrl = TextEditingController();
  
  // Controller baru untuk Nama Karyawan agar tidak menggunakan dropdown
  final _namaKaryawanCtrl = TextEditingController();

  String? _selectedUserId;
  String? _selectedBulan;
  String? _selectedTahun;

  final List<String> _bulanList = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  final List<String> _tahunList = List.generate(11, (index) => 
    (DateTime.now().year - 5 + index).toString());

  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    
    if (widget.slip != null) {
      // MODE EDIT
      _selectedUserId = widget.slip!.userId;
      _namaKaryawanCtrl.text = widget.targetUser?.name ?? "Karyawan";
      _selectedBulan = widget.slip!.bulan;
      _selectedTahun = widget.slip!.tahun;
      _gajiPokokCtrl.text = _formatter.format(widget.slip!.gajiPokok);
      _tunjanganCtrl.text = _formatter.format(widget.slip!.tunjangan);
      _potonganCtrl.text = _formatter.format(widget.slip!.potongan);
      _hitungTotal();
    } else {
      // MODE TAMBAH
      _selectedUserId = widget.targetUser?.id.toString();
      _namaKaryawanCtrl.text = widget.targetUser?.name ?? "";
      _selectedTahun = DateTime.now().year.toString();
    }
  }

  int _parseRaw(String val) => int.tryParse(val.replaceAll('.', '')) ?? 0;

  void _hitungTotal() {
    int gapok = _parseRaw(_gajiPokokCtrl.text);
    int tunjangan = _parseRaw(_tunjanganCtrl.text);
    int potongan = _parseRaw(_potonganCtrl.text);
    int total = (gapok + tunjangan) - potongan;
    _totalGajiCtrl.text = _formatter.format(total);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.slip != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Nominal Gaji" : "Buat Slip Gaji", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildGlassForm(isEdit),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassForm(bool isEdit) {
    return ClipRRect(
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
              children: [
                // SEKARANG MENGGUNAKAN FIELD BIASA (BUKAN DROPDOWN) AGAR TIDAK BISA DIUBAH
                _buildReadOnlyField(_namaKaryawanCtrl, "Karyawan", Icons.person),
                const SizedBox(height: 16),
                
                // BULAN & TAHUN: Putih Tebal (ReadOnly jika Edit, Dropdown jika Baru)
                isEdit 
                  ? _buildReadOnlyField(TextEditingController(text: _selectedBulan), "Bulan", Icons.date_range)
                  : _buildDropdownBulan(),
                const SizedBox(height: 16),
                
                isEdit 
                  ? _buildReadOnlyField(TextEditingController(text: _selectedTahun), "Tahun", Icons.calendar_today)
                  : _buildDropdownTahun(),
                
                const Divider(color: Colors.white24, height: 40),
                
                // NOMINAL GAJI
                _buildCurrencyField(_gajiPokokCtrl, "Gaji Pokok", Icons.money),
                const SizedBox(height: 16),
                _buildCurrencyField(_tunjanganCtrl, "Tunjangan", Icons.add_circle_outline),
                const SizedBox(height: 16),
                _buildCurrencyField(_potonganCtrl, "Potongan", Icons.remove_circle_outline),
                const SizedBox(height: 16),
                _buildField(_totalGajiCtrl, "Total Gaji Bersih", Icons.account_balance_wallet, readOnly: true),
                const SizedBox(height: 32),
                
                _isSaving 
                  ? const CircularProgressIndicator(color: Color(0xFFD1EBDB))
                  : _buildSubmitButton(isEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET UNTUK TAMPILAN PUTIH TEBAL & TIDAK BISA DIEDIT (UNTUK KARYAWAN/BULAN/TAHUN SAAT EDIT)
  Widget _buildReadOnlyField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      decoration: _inputDecoration(label, icon, false).copyWith(
        fillColor: Colors.black.withOpacity(0.3), // Latar lebih gelap agar teks putih menonjol
      ),
    );
  }

  Widget _buildDropdownBulan() {
    return DropdownButtonFormField<String>(
      value: _selectedBulan,
      dropdownColor: const Color(0xFF192524),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: _inputDecoration("Bulan", Icons.date_range, true),
      items: _bulanList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
      onChanged: (v) => setState(() => _selectedBulan = v),
      validator: (v) => v == null ? "Wajib diisi" : null,
    );
  }

  Widget _buildDropdownTahun() {
    return DropdownButtonFormField<String>(
      value: _selectedTahun,
      dropdownColor: const Color(0xFF192524),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: _inputDecoration("Tahun", Icons.calendar_today, true),
      items: _tahunList.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (v) => setState(() => _selectedTahun = v),
      validator: (v) => v == null ? "Wajib diisi" : null,
    );
  }

  Widget _buildCurrencyField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(label, icon, true),
      onChanged: (value) {
        if (value.isNotEmpty) {
          String formatted = _formatter.format(_parseRaw(value));
          ctrl.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
        _hitungTotal();
      },
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? const Color(0xFFD1EBDB) : Colors.white, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(label, icon, !readOnly),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool enabled) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
      filled: true, 
      fillColor: enabled ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.2),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD1EBDB))),
    );
  }

  Widget _buildSubmitButton(bool isEdit) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD1EBDB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isSaving = true);
            
            SlipGaji data = SlipGaji(
              userId: _selectedUserId,
              bulan: _selectedBulan,
              tahun: _selectedTahun,
              gajiPokok: _parseRaw(_gajiPokokCtrl.text),
              tunjangan: _parseRaw(_tunjanganCtrl.text),
              potongan: _parseRaw(_potonganCtrl.text),
              totalGaji: _parseRaw(_totalGajiCtrl.text),
            );

            bool success = isEdit 
              ? await SlipGajiService().ubah(data, widget.slip!.id!)
              : await SlipGajiService().simpan(data);

            setState(() => _isSaving = false);
            _showResultDialog(success ? "Berhasil" : "Gagal", 
              success ? "Data berhasil disimpan" : "Terjadi kesalahan server", success);
          }
        },
        child: Text(isEdit ? "UPDATE NOMINAL" : "SIMPAN SLIP GAJI", 
          style: const TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold)),
      ),
    );
  }

void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
            width: 2,
          ),
        ),
        // --- REVISI BAGIAN TITLE: IKON + TEKS BESAR ---
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
            const SizedBox(height: 10),
            Text(
              isSuccess ? "Berhasil" : "Gagal", 
              style: TextStyle(
                color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
                fontWeight: FontWeight.bold, 
                fontSize: 18, // Ukuran teks besar sesuai permintaan
              ),
            ),
          ],
        ),
        // --- BAGIAN KONTEN (PESAN) ---
        content: Text(
          message, 
          textAlign: TextAlign.center, 
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog
                if (isSuccess) {
                  Navigator.pop(context, true); // Kembali ke halaman sebelumnya jika sukses
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
}