import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
import '../helpers/user_info.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  final List<Map<String, dynamic>> dataKaryawan = [
    {
      'nama': 'Bahrudin',
      'username': 'bahrudin',
      'gaji_pokok': 4000000.0,
      'tunjangan': 500000.0,
      'insentif': 800000.0,
      'pph': 150000.0,
      'bpjs': 100000.0,
    },
    {
      'nama': 'Cantika Ayu',
      'username': 'Cantika Ayu',
      'gaji_pokok': 4100000.0,
      'tunjangan': 600000.0,
      'insentif': 900000.0,
      'pph': 160000.0,
      'bpjs': 100000.0,
    },
    {
      'nama': 'Aditya S',
      'username': 'Aditiya S',
      'gaji_pokok': 3900000.0,
      'tunjangan': 400000.0,
      'insentif': 700000.0,
      'pph': 140000.0,
      'bpjs': 90000.0,
    },
    {
      'nama': 'Denis',
      'username': 'denis',
      'gaji_pokok': 4000000.0,
      'tunjangan': 550000.0,
      'insentif': 850000.0,
      'pph': 155000.0,
      'bpjs': 95000.0,
    },
  ];

  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filterData();
  }

  void filterData() {
    final isAdmin = UserInfo.role == 'admin';
    final username = UserInfo.username;

    if (isAdmin) {
      filteredData = dataKaryawan;
    } else {
      filteredData = dataKaryawan
          .where((k) =>
              k['username'].toString().toLowerCase() ==
              username?.toLowerCase())
          .toList();
    }

    setState(() {});
  }

  Widget buildSlipCard(Map<String, dynamic> karyawan) {
    double gajiPokok = karyawan['gaji_pokok'];
    double tunjangan = karyawan['tunjangan'];
    double insentif = karyawan['insentif'];
    double pph = karyawan['pph'];
    double bpjs = karyawan['bpjs'];

    double totalPendapatan = gajiPokok + tunjangan + insentif;
    double totalPotongan = pph + bpjs;
    double gajiBersih = totalPendapatan - totalPotongan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(

        gradient: const LinearGradient(
          colors: [Color(0xFF2E3A3F), Color(0xFF3C4B52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 4)),
        ],
        border: Border.all(color: Colors.white24),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [

                Icon(Icons.receipt_long, size: 40, color: Colors.white70),
                SizedBox(height: 8),
                Text(
                  'Slip Gaji Karyawan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Divider(thickness: 1, color: Colors.white24),

              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildRow('Nama Karyawan', karyawan['nama']),
          const SizedBox(height: 12),

          const Text('Pendapatan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),

          _buildRow('Gaji Pokok', 'Rp ${gajiPokok.toStringAsFixed(0)}'),
          _buildRow('Tunjangan', 'Rp ${tunjangan.toStringAsFixed(0)}'),
          _buildRow('Insentif', 'Rp ${insentif.toStringAsFixed(0)}'),
          const SizedBox(height: 12),

          const Text('Potongan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          _buildRow('PPh (Pajak Penghasilan)', '- Rp ${pph.toStringAsFixed(0)}'),
          _buildRow('BPJS (Kesehatan & Ketenagakerjaan)', '- Rp ${bpjs.toStringAsFixed(0)}'),
          const Divider(thickness: 1, color: Colors.white24),
          _buildRow('Total Diterima', 'Rp ${gajiBersih.toStringAsFixed(0)}', isBold: true),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'PT. Naga Hytam',

              style: TextStyle(color: Colors.grey.shade300),

            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(

                color: Colors.white,


                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(

              color: Colors.white,


              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          'Slip Gaji PT. Naga Hytam Sejahter Abadi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101C1D), Color(0xFF1C2B2D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

  
        padding: const EdgeInsets.all(16.0),
        child: filteredData.length == 1
            ? Center(
                child: SizedBox(
                  width: 320,
                  child: buildSlipCard(filteredData[0]),
                ),
              )
            : GridView.builder(
                itemCount: filteredData.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3 / 4.5,
                ),
                itemBuilder: (context, index) {
                  return buildSlipCard(filteredData[index]);
                },
              ),
      ),
    );
  }
}
