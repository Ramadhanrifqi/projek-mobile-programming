import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../model/slip_gaji.dart';
import '../model/user.dart';
import '../service/slip_gaji_service.dart';

class SlipGajiFormPage extends StatefulWidget {
  final SlipGaji? slip;
  final User? targetUser;

  const SlipGajiFormPage({super.key, this.slip, this.targetUser});

  @override
  State<SlipGajiFormPage> createState() => _SlipGajiFormPageState();
}

class _SlipGajiFormPageState extends State<SlipGajiFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  final _gajiPokokCtrl = TextEditingController();
  final _tunjTransportCtrl = TextEditingController();
  final _tunjMakanCtrl = TextEditingController();
  final _pph21Ctrl = TextEditingController();
  final _bpjsKesCtrl = TextEditingController();
  final _bpjsTkCtrl = TextEditingController();
  final _totalGajiCtrl = TextEditingController();
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
      _gajiPokokCtrl.text = _formatter.format(widget.slip!.gajiPokok ?? 0);
      _tunjTransportCtrl.text = _formatter.format(widget.slip!.tunjanganTransport ?? 0);
      _tunjMakanCtrl.text = _formatter.format(widget.slip!.tunjanganMakan ?? 0);
      _hitungOtomatis();
    } else {
      // MODE TAMBAH
      _selectedUserId = widget.targetUser?.id.toString();
      _namaKaryawanCtrl.text = widget.targetUser?.name ?? "";
      _selectedTahun = DateTime.now().year.toString();
    }
  }

  int _parseRaw(String val) {
    if (val.isEmpty) return 0; // Kembalikan 0 jika input kosong
    return int.tryParse(val.replaceAll('.', '')) ?? 0;
  }

  void _hitungOtomatis() {
    int gapok = _parseRaw(_gajiPokokCtrl.text);
    int transport = _parseRaw(_tunjTransportCtrl.text);
    int makan = _parseRaw(_tunjMakanCtrl.text);

    int bruto = gapok + transport + makan;

    // Perhitungan Potongan Sesuai Aturan PT Naga Hytam
    int bpjsKes = (bruto * 0.01).round();
    int bpjsTk = (bruto * 0.02).round();
    int pph21 = (bruto > 4500000) ? (bruto * 0.05).round() : 0;

    int totalPotongan = bpjsKes + bpjsTk + pph21;
    int netto = bruto - totalPotongan;

    _bpjsKesCtrl.text = _formatter.format(bpjsKes);
    _bpjsTkCtrl.text = _formatter.format(bpjsTk);
    _pph21Ctrl.text = _formatter.format(pph21);
    _totalGajiCtrl.text = _formatter.format(netto);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.slip != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Slip Gaji" : "Buat Slip Gaji", 
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadOnlyField(_namaKaryawanCtrl, "Karyawan", Icons.person),
                const SizedBox(height: 16),
                
                isEdit 
                  ? _buildReadOnlyField(TextEditingController(text: _selectedBulan), "Bulan", Icons.date_range)
                  : _buildDropdownBulan(),
                const SizedBox(height: 16),
                
                isEdit 
                  ? _buildReadOnlyField(TextEditingController(text: _selectedTahun), "Tahun", Icons.calendar_today)
                  : _buildDropdownTahun(),
                
                const Divider(color: Colors.white24, height: 40),
                const Text("PENDAPATAN", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                
                _buildCurrencyField(_gajiPokokCtrl, "Gaji Pokok", Icons.money, isRequired: true),
                const SizedBox(height: 16),
                _buildCurrencyField(_tunjTransportCtrl, "Tunjangan Transport (Opsional)", Icons.directions_bus),
                const SizedBox(height: 16),
                _buildCurrencyField(_tunjMakanCtrl, "Tunjangan Makan (Opsional)", Icons.restaurant),
                
                const Divider(color: Colors.white24, height: 40),
                const Text("POTONGAN OTOMATIS", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),

                _buildReadOnlyField(_pph21Ctrl, "PPh 21 (5% jika > 4.5jt)", Icons.account_balance),
                const SizedBox(height: 12),
                _buildReadOnlyField(_bpjsKesCtrl, "BPJS Kesehatan (1%)", Icons.health_and_safety),
                const SizedBox(height: 12),
                _buildReadOnlyField(_bpjsTkCtrl, "BPJS Ketenagakerjaan (2%)", Icons.work_history),
                
                const Divider(color: Colors.white24, height: 40),
                _buildField(_totalGajiCtrl, "Total Gaji Bersih (Netto)", Icons.account_balance_wallet, readOnly: true),
                const SizedBox(height: 32),
                
                _isSaving 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                  : _buildSubmitButton(isEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      decoration: _inputDecoration(label, icon, false),
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

  Widget _buildCurrencyField(TextEditingController ctrl, String label, IconData icon, {bool isRequired = false}) {
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
        _hitungOtomatis();
      },
      // Tunjangan kini opsional, hanya Gaji Pokok yang dicek isNotEmpty
      validator: (v) => (isRequired && (v == null || v.isEmpty)) ? "Wajib diisi" : null,
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? const Color(0xFFD1EBDB) : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      decoration: _inputDecoration(label, icon, !readOnly),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool enabled) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFD1EBDB), size: 20),
      filled: true, 
      fillColor: enabled ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.2),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
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
              tunjanganTransport: _parseRaw(_tunjTransportCtrl.text),
              tunjanganMakan: _parseRaw(_tunjMakanCtrl.text),
              totalGaji: _parseRaw(_totalGajiCtrl.text),
            );

            bool success = isEdit 
              ? await SlipGajiService().ubah(data, widget.slip!.id!)
              : await SlipGajiService().simpan(data);

            setState(() => _isSaving = false);
            _showResultDialog(success ? "Berhasil" : "Gagal", 
              success ? "Data slip gaji berhasil disimpan" : "Terjadi kesalahan server", success);
          }
        },
        child: Text(isEdit ? "UPDATE SLIP GAJI" : "SIMPAN SLIP GAJI", 
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
          side: BorderSide(color: isSuccess ? Colors.greenAccent : Colors.redAccent, width: 2),
        ),
        title: Column(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error_outline, 
              color: isSuccess ? Colors.greenAccent : Colors.redAccent, size: 50),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: isSuccess ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (isSuccess) Navigator.pop(context, true);
              },
              child: const Text("OK", style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}