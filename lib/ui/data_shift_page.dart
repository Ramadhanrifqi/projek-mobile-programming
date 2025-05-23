import 'package:flutter/material.dart';

class DataShiftPage extends StatelessWidget {
  final List<String> days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  final List<String> employees = [
    'Karyawan A', 'Karyawan B', 'Karyawan C', 'Karyawan D',
  ];

  final List<List<String>> shiftData = [
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
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Data Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jadwal Shift Mingguan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Lihat pembagian shift karyawan setiap hari.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateProperty.all(Colors.indigo.shade100),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                      dataTextStyle: const TextStyle(fontSize: 14),
                      columns: [
                        const DataColumn(label: Text('Hari')),
                        ...employees.map((e) => DataColumn(label: Text(e))),
                      ],
                      rows: List.generate(days.length, (i) {
                        return DataRow(
                          cells: [
                            DataCell(Text(days[i])),
                            ...shiftData[i].map((shift) {
                              return DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: getShiftColor(shift),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  shift,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: getShiftTextColor(shift),
                                  ),
                                ),
                              ));
                            }).toList(),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
