import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import 'cuti_form.dart';
import 'poli_item.dart';
import '../widget/sidebar.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  _CutiPageState createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  /// Mengambil daftar Cuti dari service sebagai Future
  Future<List<Cuti>> getList() async {
    return await CutiService().listData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(args)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Data Pegajuan Cuti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate ke form, tunggu hingga kembali, lalu refresh data
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CutiForm()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Cuti>>(
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
              return PoliItem(cuti: polis[index]);
            },
          );
        },
      ),
    );
  }
}
