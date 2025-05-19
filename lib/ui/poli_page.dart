import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_form.dart';
import 'poli_item.dart';
import '../widget/sidebar.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});

  @override
  _PoliPageState createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage> {
  /// Mengambil daftar Poli dari service sebagai Future
  Future<List<Poli>> getList() async {
    return await PoliService().listData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Data Poli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate ke form, tunggu hingga kembali, lalu refresh data
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PoliForm()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Poli>>(
        future: getList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data kosong'));
          }

          final polis = snapshot.data!;
          return ListView.builder(
            itemCount: polis.length,
            itemBuilder: (context, index) {
              return PoliItem(poli: polis[index]);
            },
          );
        },
      ),
    );
  }
}
