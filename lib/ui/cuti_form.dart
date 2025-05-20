import 'package:flutter/material.dart';
import '../model/cuti.dart';
import '../service/cuti_service.dart';
import 'cuti_page.dart';

class CutiForm extends StatefulWidget {
  const CutiForm({Key? key}) : super(key: key);

  @override
  _CutiFormState createState() => _CutiFormState();
}

class _CutiFormState extends State<CutiForm> {
  final _formKey = GlobalKey<FormState>();
  final _ajukanCutiCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Cuti")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _fieldNama(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Nama Cuti",
        border: OutlineInputBorder(),
      ),
      controller: _ajukanCutiCtrl,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama Cuti tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _tombolSimpan() {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _simpanCuti,
            child: const Text("Simpan"),
          );
  }

  Future<void> _simpanCuti() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Cuti cuti = Cuti(ajukanCuti: _ajukanCutiCtrl.text);
        final value = await CutiService().simpan(cuti);

        if (!mounted) return;
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CutiPage(),
          settings: RouteSettings(
            arguments: 'Data berhasil disimpan',
          ),
        ),
      );

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _ajukanCutiCtrl.dispose();
    super.dispose();
  }
}