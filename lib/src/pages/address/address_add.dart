import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressAddPage extends StatefulWidget {
  final int? id;
  final String? kota;
  final String? alamat;
  final String? alamatToko;

  const AddressAddPage({
    super.key,
    this.id,
    this.kota,
    this.alamat,
    this.alamatToko,
  });

  @override
  State<AddressAddPage> createState() => _AddressAddPageState();
}

class _AddressAddPageState extends State<AddressAddPage> {
  final SessionManager sessionManager = SessionManager();

  final _kotaController = TextEditingController();
  final _alamatController = TextEditingController();
  final List<Map<String, dynamic>> _itemsSetToko = [
    {'value': 'Y', 'text': 'Ya'},
    {'value': 'N', 'text': 'Tidak'},
  ];

  bool _isLoading = false;
  Map<String, dynamic>? _selectedSetToko;

  @override
  void initState() {
    super.initState();

    if (widget.alamatToko == 'Y') {
      setState(() {
        _selectedSetToko = _itemsSetToko.firstWhere(
          (item) => item['value'] == 'Y',
        );
      });
    } else {
      setState(() {
        _selectedSetToko = _itemsSetToko.firstWhere(
          (item) => item['value'] == 'N',
        );
      });
    }

    setState(() {
      _kotaController.text = widget.kota ?? '';
      _alamatController.text = widget.alamat ?? '';
    });
  }

  void _simpan(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    var token = await sessionManager.getSession('token');

    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.postData(
        'alamat/add',
        {
          'id': widget.id ?? '',
          'kota': _kotaController.text,
          'alamat': _alamatController.text,
          'alamat_toko': _selectedSetToko!['value'] ?? 'N',
        },
        token: token,
      );

      if (dataProvider.data['success']) {
        Navigator.pop(context);
      } else {
        print("Data gagal disimpan: ${dataProvider.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Data gagal disimpan: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during Data gagal disimpan: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Data gagal disimpan, please try again.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.id != null
            ? const Text('Edit Alamat')
            : const Text('Tambah Alamat'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextFormField(
              controller: _kotaController,
              decoration: const InputDecoration(
                labelText: 'Kota',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            // Link input
            TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            if (widget.alamatToko!.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadikan Alamat Toko',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih'),
                    value: _selectedSetToko,
                    items: _itemsSetToko.map((Map<String, dynamic> item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Text(
                          item['text'],
                        ),
                      );
                    }).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        _selectedSetToko = value;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _isLoading ? print('loading') : _simpan(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16), // Tinggi tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: _isLoading
                      ? const Color(0xFFA4A4A4)
                      : const Color(0xFFff9000),
                ),
                child: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
