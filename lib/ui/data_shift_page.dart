import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

// Halaman untuk menampilkan jadwal shift mingguan karyawan
class DataShiftPage extends StatelessWidget {
  const DataShiftPage({Key? key}) : super(key: key);

  // Daftar hari kerja
  final List<String> days = const [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
  ];

  // Daftar nama karyawan
  final List<String> employees = const [
    'Aditiya S', 'Bahrudin', 'Cantika Ayu', 'Denis',
  ];

  // Data shift tiap hari untuk masing-masing karyawan
  final List<List<String>> shiftData = const [
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Malam', 'Pagi', 'Malam'],
    ['Malam', 'Malam', 'Pagi', 'Pagi'],
    ['Malam', 'Malam', 'Pagi', 'Pagi'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
  ];

  // Warna latar shift berdasarkan jenisnya
  Color getShiftColor(String shift) {
    return shift == 'Pagi'
      ? const Color(0xFF192524) // warna shift pagi
      : const Color(0xFF3C5759); // warna shift malam
  }

  // Warna teks shift berdasarkan jenisnya
  Color getShiftTextColor(String shift) {
    return shift == 'Pagi'
        ? const Color(0xFF3C5759)
        : const Color(0xFF192524);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(), // Navigasi samping
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192524), Color(0xFF3C5759)], // Gradasi latar belakang
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar transparan
              AppBar(
                title: const Text('Jadwal Shift Mingguan', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: true,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              // Daftar shift dalam bentuk card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: days.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 4,
                        color: Colors.white.withOpacity(0.25),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul hari
                              Text(
                                days[i],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // List shift per karyawan di hari tersebut
                              ...List.generate(employees.length, (j) {
                                final shift = shiftData[i][j];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: getShiftColor(shift),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Nama karyawan
                                      Text(
                                        employees[j],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        ),
                                      ),
                                      // Jenis shift
                                      Text(
                                        shift,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: getShiftTextColor(shift),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
