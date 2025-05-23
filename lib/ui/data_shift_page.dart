import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
class DataShiftPage extends StatelessWidget {
  const DataShiftPage({Key? key}) : super(key: key);

  final List<String> days = const [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  final List<String> employees = const [
    'Karyawan A', 'Karyawan B', 'Karyawan C', 'Karyawan D',
  ];

  final List<List<String>> shiftData = const [
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Malam', 'Pagi', 'Malam'],
    ['Malam', 'Malam', 'Pagi', 'Pagi'],
    ['Malam', 'Malam', 'Pagi', 'Pagi'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
    ['Pagi', 'Pagi', 'Malam', 'Malam'],
  ];

  Color getShiftColor(String shift) {
    return shift == 'Pagi' ? Colors.lightBlue.shade100 : Colors.deepPurple.shade100;
  }

  Color getShiftTextColor(String shift) {
    return shift == 'Pagi' ? Colors.indigo : Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Jadwal Shift Mingguan'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, i) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      days[i],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            Text(
                              employees[j],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
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
    );
  }
}
