import 'package:flutter/material.dart';
import '../widget/sidebar.dart';

class DataShiftPage extends StatelessWidget {
  const DataShiftPage({Key? key}) : super(key: key);

  final List<String> days = const [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
  ];

  final List<String> employees = const [
    'Aditiya S', 'Bahrudin', 'Cantika Ayu', 'Denis',
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
    return shift == 'Pagi'
      ? const Color(0xFF192524)
      : const Color(0xFF3C5759);
  }

  Color getShiftTextColor(String shift) {
    return shift == 'Pagi'
        ? const Color(0xFF3C5759)
        : const Color(0xFF192524);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const Sidebar(),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF192524), Color(0xFF3C5759)], // Atas ke bawah
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text('Jadwal Shift Mingguan',style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: true,
                iconTheme: const IconThemeData(color: Colors.white),
            ),
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
                            Text(
                              days[i],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                      ),
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
            ),
          ],
        ),
      ),
    ),
  );
}

}
