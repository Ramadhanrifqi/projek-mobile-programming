import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
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

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    final allSlip = await SlipGajiService().getAllSlip();
    
    List<SlipGaji> filtered = allSlip.where((s) => s.userId == widget.user.id.toString()).toList();
    
    filtered.sort((a, b) {
      int idA = int.tryParse(a.id.toString()) ?? 0;
      int idB = int.tryParse(b.id.toString()) ?? 0;
      return idB.compareTo(idA); 
    });

    setState(() {
      _allRiwayat = filtered;
      _filteredRiwayat = filtered;
      _isLoading = false;
    });
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

  // --- POP UP DETAIL SELURUH GAJI ---
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.white24),
            _rowDetail("Gaji Pokok", slip.gajiPokok),
            _rowDetail("Tunjangan", slip.tunjangan),
            _rowDetail("Potongan", slip.potongan, isMinus: true),
            const Divider(color: Colors.white24, thickness: 1),
            _rowDetail("Total Bersih", slip.totalGaji, isTotal: true),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("TUTUP", 
                style: TextStyle(color: Color(0xFFD1EBDB), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, dynamic value, {bool isMinus = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(
            "${isMinus ? '- ' : ''}Rp ${_formatter.format(int.tryParse(value.toString()) ?? 0)}",
            style: TextStyle(
              color: isTotal ? const Color(0xFFD1EBDB) : (isMinus ? Colors.redAccent : Colors.white),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 15,
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
    // LOGIKA PEER REVIEW: 
    // 1. Cek apakah saya Admin
    final isAdmin = UserInfo.role?.toLowerCase() == 'admin';
    // 2. Cek apakah saya sedang melihat data SAYA SENDIRI
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
                    : _filteredRiwayat.isEmpty
                        ? const Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.white60)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredRiwayat.length,
                            itemBuilder: (context, index) => _buildHistoryCard(_filteredRiwayat[index], isAdmin, isMe),
                          ),
              ),
            ],
          ),
        ),
      ),
      // Tombol Tambah HANYA muncul jika saya Admin DAN BUKAN data milik saya
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
        subtitle: Text("Total: Rp ${_formatter.format(slip.totalGaji)}", style: const TextStyle(color: Color(0xFFD1EBDB))),
        trailing: (isAdmin && !isMe) // Jika Admin dan bukan data milik sendiri, tampilkan Edit & Hapus
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