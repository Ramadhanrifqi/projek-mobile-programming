import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:printing/printing.dart'; 
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw; 
import '../model/user.dart';
import '../model/slip_gaji.dart';
import '../service/slip_gaji_service.dart';
import '../helpers/user_info.dart';
import 'slip_gaji_form_page.dart';

class SlipGajiDetailPage extends StatefulWidget {
  final User user;
  const SlipGajiDetailPage({super.key, required this.user});

  @override
  State<SlipGajiDetailPage> createState() => _SlipGajiDetailPageState();
}

class _SlipGajiDetailPageState extends State<SlipGajiDetailPage> {
  List<SlipGaji> _allRiwayat = [];
  List<SlipGaji> _filteredRiwayat = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  // MODIFIKASI: Menambahkan parameter isRefresh agar loading tidak menutupi layar jika ditarik
  Future<void> _fetchRiwayat({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);
    
    final allSlip = await SlipGajiService().getAllSlip(); 
    
    List<SlipGaji> filtered = allSlip.where((s) => s.userId == widget.user.id.toString()).toList();
    
    filtered.sort((a, b) {
      int idA = int.tryParse(a.id.toString()) ?? 0;
      int idB = int.tryParse(b.id.toString()) ?? 0;
      return idB.compareTo(idA); 
    });

    if (mounted) {
      setState(() {
        _allRiwayat = filtered;
        _filteredRiwayat = filtered;
        _isLoading = false;
      });
    }
  }

  void _runFilter(String keyword) {
    List<SlipGaji> results = [];
    if (keyword.isEmpty) {
      results = _allRiwayat;
    } else {
      results = _allRiwayat.where((s) {
        final bulan = (s.bulan ?? "").toLowerCase();
        final tahun = (s.tahun ?? "").toLowerCase();
        return bulan.contains(keyword.toLowerCase()) || tahun.contains(keyword.toLowerCase());
      }).toList();
    }
    setState(() => _filteredRiwayat = results);
  }

  Future<void> _generatePdf(SlipGaji slip) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("SLIP GAJI KARYAWAN", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(child: pw.Text("PT NAGA HYTAM SEJAHTERA ABADI", style: const pw.TextStyle(fontSize: 10))),
                pw.SizedBox(height: 20),
                pw.Text("Nama: ${widget.user.name}"),
                pw.Text("Periode: ${slip.bulan} ${slip.tahun}"),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _pdfRow("Gaji Pokok", slip.gajiPokok),
                _pdfRow("Tunjangan Transport", slip.tunjanganTransport),
                _pdfRow("Tunjangan Makan", slip.tunjanganMakan),
                pw.SizedBox(height: 5),
                _pdfRow("PPh 21 (5%)", slip.potonganPph21, isMinus: true),
                _pdfRow("BPJS Kesehatan (1%)", slip.potonganBpjsKes, isMinus: true),
                _pdfRow("BPJS Ketenagakerjaan (2%)", slip.potonganBpjsTk, isMinus: true),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL GAJI BERSIH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Rp ${_formatter.format(slip.totalGaji)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("TTD Management", style: const pw.TextStyle(fontSize: 8)),
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfRow(String label, dynamic value, {bool isMinus = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text("${isMinus ? '- ' : ''}Rp ${_formatter.format(value ?? 0)}", style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  void _showRincianDialog(SlipGaji slip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD1EBDB), width: 1),
        ),
        title: Column(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFFD1EBDB), size: 40),
            const SizedBox(height: 10),
            const Text("Detail Slip Gaji", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("${slip.bulan} ${slip.tahun}", 
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Colors.white24),
              _rowDetail("Gaji Pokok", slip.gajiPokok),
              _rowDetail("Tunj. Transport", slip.tunjanganTransport),
              _rowDetail("Tunj. Makan", slip.tunjanganMakan),
              const Divider(color: Colors.white10),
              _rowDetail("PPh 21 (5%)", slip.potonganPph21, isMinus: true),
              _rowDetail("BPJS Kes (1%)", slip.potonganBpjsKes, isMinus: true),
              _rowDetail("BPJS TK (2%)", slip.potonganBpjsTk, isMinus: true),
              const Divider(color: Colors.white24, thickness: 1),
              _rowDetail("Total Bersih", slip.totalGaji, isTotal: true),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generatePdf(slip),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("CETAK PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1EBDB),
                    foregroundColor: const Color(0xFF192524),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("TUTUP", 
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, dynamic value, {bool isMinus = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            "${isMinus ? '- ' : ''}Rp ${_formatter.format(int.tryParse(value.toString()) ?? 0)}",
            style: TextStyle(
              color: isTotal ? const Color(0xFFD1EBDB) : (isMinus ? Colors.redAccent : Colors.white),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(SlipGaji slip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 50),
            SizedBox(height: 10),
            Text("Hapus Slip Gaji",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          "Hapus riwayat gaji ${slip.bulan} ${slip.tahun}?\nData yang dihapus tidak dapat dikembalikan.", 
          textAlign: TextAlign.center, 
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: const Text("Batal", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))
              ),
              const SizedBox(width: 30),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  bool sukses = await SlipGajiService().hapus(slip.id.toString());
                  if (sukses) {
                    _showResultDialog("Berhasil", "Data riwayat gaji telah dihapus", true);
                    _fetchRiwayat();
                  } else {
                    _showResultDialog("Gagal", "Terjadi kesalahan saat menghapus data", false);
                  }
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF192524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSuccess ? const Color(0xFFD1EBDB) : Colors.redAccent, 
            width: 2
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline, 
              color: isSuccess ? Colors.greenAccent : Colors.redAccent, 
              size: 50
            ),
            const SizedBox(height: 10),
            Text(
              isSuccess ? "Berhasil" : "Gagal",
              style: TextStyle(
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          message, 
          textAlign: TextAlign.center, 
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          Center(
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
    final isAdmin = UserInfo.role?.toLowerCase() == 'admin';
    final isMe = UserInfo.userId == widget.user.id.toString();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Riwayat Gaji ${widget.user.name}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari bulan atau tahun...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD1EBDB)),
                    filled: true, fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
                    : RefreshIndicator(
                        // FITUR REFRESH: Memanggil kembali fungsi fetch data
                        onRefresh: () => _fetchRiwayat(isRefresh: true),
                        color: const Color(0xFF192524),
                        backgroundColor: const Color(0xFFD1EBDB),
                        child: _filteredRiwayat.isEmpty
                            ? ListView( // Gunakan ListView agar area bisa ditarik meski kosong
                                children: const [
                                  SizedBox(height: 200),
                                  Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.white60))),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemCount: _filteredRiwayat.length,
                                itemBuilder: (context, index) => _buildHistoryCard(_filteredRiwayat[index], isAdmin, isMe),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (isAdmin && !isMe)
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFD1EBDB),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SlipGajiFormPage(targetUser: widget.user)))
                    .then((value) { if (value == true) _fetchRiwayat(); });
              },
              icon: const Icon(Icons.add, color: Color(0xFF192524)),
              label: const Text("Tambah Slip", style: TextStyle(color: Color(0xFF192524), fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHistoryCard(SlipGaji slip, bool isAdmin, bool isMe) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showRincianDialog(slip),
        title: Text("${slip.bulan} ${slip.tahun}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("Total Bersih: Rp ${_formatter.format(slip.totalGaji)}", style: const TextStyle(color: Color(0xFFD1EBDB))),
        trailing: (isAdmin && !isMe)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.amberAccent),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SlipGajiFormPage(slip: slip, targetUser: widget.user)))
                          .then((value) { if (value == true) _fetchRiwayat(); });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _konfirmasiHapus(slip),
                  ),
                ],
              )
            : const Icon(Icons.info_outline, color: Colors.white54),
      ),
    );
  }
}