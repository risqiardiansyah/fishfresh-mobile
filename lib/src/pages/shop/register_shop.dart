import 'dart:convert';
import 'dart:io';

import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegisterShop extends StatefulWidget {
  final int? id;

  const RegisterShop({
    super.key,
    this.id,
  });

  @override
  State<RegisterShop> createState() => _RegisterShopState();
}

class _RegisterShopState extends State<RegisterShop> {
  final SessionManager sessionManager = SessionManager();

  File? _ktp;
  String? _ktpBase64;
  final _shopNameController = TextEditingController();
  final _shopLocationController = TextEditingController();
  final _rekeningNoController = TextEditingController();
  final _rekeningNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickKtp() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      List<int> imageBytes = await imageFile.readAsBytes();

      String base64Image = base64Encode(imageBytes);

      setState(() {
        _ktp = imageFile;
        _ktpBase64 = 'data:image/png;base64,${base64Image.toString()}';
      });

      print('Base64 Image: $base64Image');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _simpan(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    var token = await sessionManager.getSession('token');

    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.postData(
        'shops/request',
        {
          'id': widget.id ?? '',
          'shop_name': _shopNameController.text,
          'shop_location': _shopLocationController.text,
          'ktp': _ktpBase64,
          'rekening_no': _rekeningNoController.text,
          'rekening_name': _rekeningNameController.text,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: widget.id != null
            ? const Text('Pengajuan Ulang Toko')
            : const Text('Pengajuan Toko'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title input
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Usaha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_business_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                // Link input
                TextFormField(
                  controller: _shopLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Usaha',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _rekeningNoController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Rekening',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _rekeningNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemilik Rekening',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Foto KTP',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: _pickKtp,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _ktp == null
                        ? Icon(
                            Icons.add_photo_alternate,
                            color: Colors.grey[700],
                            size: 100,
                          )
                        : Image.file(
                            _ktp!,
                            fit: BoxFit.cover,
                          ),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 16), // Tinggi tombol
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
        ],
      ),
    );
  }
}
