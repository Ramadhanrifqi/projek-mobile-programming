import 'package:flutter/material.dart';
import '../model/cuti.dart';
import 'cuti_detail.dart';

class PoliItem extends StatelessWidget {
  final Cuti cuti;

  const PoliItem({super.key, required this.cuti});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: ListTile(
          title: Text(cuti.ajukanCuti),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CutiDetail(cuti: cuti)),
        );
      },
    );
  }
}
