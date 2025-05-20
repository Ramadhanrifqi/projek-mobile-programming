import 'package:flutter/material.dart';
import '../service/cuti_service.dart';
import 'cuti_page.dart';
import 'cuti_update_form.dart';
import '../model/cuti.dart';

class CutiDetail extends StatefulWidget {
  final Cuti cuti;

  const CutiDetail({super.key, required this.cuti});
  @override
  // ignore: library_private_types_in_public_api
  _CutiDetaileState createState() => _CutiDetaileState();
}

class _CutiDetaileState extends State<CutiDetail> {
  Stream<Cuti> getData() async* {
    Cuti data = await CutiService().getById(widget.cuti.id.toString());
    yield data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nama")),
      body: StreamBuilder(
        stream: getData(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return const Text('Data Tidak Ditemukan');
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Nama Karyawan : ${snapshot.data.ajukanCuti}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_tombolUbah(), _tombolHapus()],
              )
            ],
          );
        },
      ),
    );
  }

  _tombolUbah() {
    return StreamBuilder(
      stream: getData(),
      builder: (context, AsyncSnapshot snapshot) => ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CutiUpdate(cuti: snapshot.data),
            ),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Ubah"),
      ),
    );
  }

  _tombolHapus() {
    return ElevatedButton(
      onPressed: () {
        AlertDialog alertDialog = AlertDialog(
          content: const Text("Yakin ingin menghapus data ini?"),
          actions: [
            StreamBuilder(
              stream: getData(),
              builder: (context, AsyncSnapshot snapshot) => ElevatedButton(
                onPressed: () async {
                  await CutiService().hapus(snapshot.data).then((value) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => CutiPage(),
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("YA"),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Tidak"),
            )
          ],
        );
        showDialog(context: context, builder: (context) => alertDialog);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("Hapus"),
    );
  }
}