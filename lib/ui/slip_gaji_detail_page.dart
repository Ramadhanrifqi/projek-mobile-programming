import 'package:flutter/material.dart';
import '../model/slip_gaji.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl di pubspec.yaml

class SlipGajiDetailPage extends StatelessWidget {
  final SlipGaji slip;

  const SlipGajiDetailPage({super.key, required this.slip});

  // Fungsi format Rupiah
  String formatRupiah(int? nominal) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(nominal ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Slip Gaji"),
        backgroundColor: const Color(0xFF192524),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.tealAccent, size: 50),
                  const SizedBox(height: 10),
                  Text("${slip.bulan} ${slip.tahun}",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24, height: 30),
                  
                  _rowDetail("Gaji Pokok", formatRupiah(slip.gajiPokok)),
                  _rowDetail("Tunjangan", formatRupiah(slip.tunjangan)),
                  _rowDetail("Potongan", "- ${formatRupiah(slip.potongan)}", isNegative: true),
                  
                  const Divider(color: Colors.white24, height: 30),
                  _rowDetail("Total Gaji Bersih", formatRupiah(slip.totalGaji), isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value, {bool isNegative = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: isTotal ? 16 : 14)),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? Colors.redAccent : (isTotal ? Colors.tealAccent : Colors.white),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}