import 'dart:ui';
import 'package:flutter/material.dart';
import '../service/slip_gaji_service.dart';
import '../model/slip_gaji.dart';
import '../widget/sidebar.dart';
import 'slip_gaji_detail_page.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  List<SlipGaji> _listSlip = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _listSlip = await SlipGajiService().getAllSlip();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Slip Gaji", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1EBDB)))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFFD1EBDB),
                  child: _listSlip.isEmpty
                      ? const Center(child: Text("Belum ada riwayat gaji", style: TextStyle(color: Colors.white60)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _listSlip.length,
                          itemBuilder: (context, index) {
                            final slip = _listSlip[index];
                            return _buildSlipCard(slip);
                          },
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildSlipCard(SlipGaji slip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFFD1EBDB), size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slip.bulan ?? "Bulan", 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Tahun: ${slip.tahun}", 
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SlipGajiDetailPage(slip: slip),
    ),
  );
},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}