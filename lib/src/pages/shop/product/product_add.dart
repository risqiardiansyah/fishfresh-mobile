import 'dart:convert';
import 'dart:io';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProductAdd extends StatefulWidget {
  final int? id;
  const ProductAdd({
    super.key,
    this.id,
  });

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final SessionManager sessionManager = SessionManager();

  final List<File> _images = [];
  final List<String> _imagesBase64 = [];
  List<dynamic> _itemsJenis = [];
  final List<Map<String, dynamic>> _itemsAsuransi = [
    {'value': 'Y', 'text': 'Ya'},
    {'value': 'N', 'text': 'Tidak'},
  ];
  final _beratController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _diskonController = TextEditingController();
  final _stockController = TextEditingController();

  bool _isLoading = false;

  Map<String, dynamic>? _selectedJenis;
  Map<String, dynamic>? _selectedAsuransi;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });

    setState(() {
      _imagesBase64.removeWhere((item) => item != 'x');
    });
    for (var image in _images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      setState(() {
        _imagesBase64.add('data:image/png;base64,${base64Image.toString()}');
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _imagesBase64.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();

    initData(context);
  }

  void initData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('shops/jenis', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          _itemsJenis = dataProvider.data['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Sedang ada error pada sistem, harap hubungi admin")));
      }
    } catch (error) {
      print("Error during init: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed, please try again.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _simpan(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    var token = await sessionManager.getSession('token');

    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.postData(
        'product/add',
        {
          'id': widget.id ?? '',
          'images': _imagesBase64,
          'jenis_id': _selectedJenis!['value'] ?? '',
          'asuransi': _selectedAsuransi!['value'] ?? '',
          'berat': _beratController.text,
          'deskripsi': _deskripsiController.text,
          'nama_produk': _namaProdukController.text,
          'harga': _hargaController.text,
          'diskon': _diskonController.text,
          'stock': _stockController.text,
        },
        token: token,
      );

      print(dataProvider.data['success']);

      if (dataProvider.data['success']) {
        Navigator.pop(context);
      } else {
        print("Data gagal disimpan xx: ${dataProvider.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Data gagal disimpan: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Data gagal disimpan: $error");
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
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Gambar Produk',
                style: TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // Menampilkan grid gambar yang dipilih
              _images.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Scroll ke kanan
                      child: Row(
                        children: _images.map((image) {
                          int index = _images.indexOf(image);
                          return Stack(
                            children: [
                              // Gambar yang dipilih
                              Container(
                                margin: const EdgeInsets.all(10),
                                width: 100,
                                height: 100,
                                child: Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Tombol close merah untuk menghapus gambar
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: Row(
                          children: [
                            Text(
                              'Belum ada foto dipilih',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ),

              ElevatedButton(
                onPressed: _pickImages,
                child: const Text(
                  'Tambah Gambar',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaProdukController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Produk',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jenis Ikan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Jenis Ikan'),
                    value: _selectedJenis,
                    items: _itemsJenis.map((dynamic item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Text(
                          item['text'],
                        ),
                      );
                    }).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        _selectedJenis = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asuransi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Asuransi'),
                    value: _selectedAsuransi,
                    items: _itemsAsuransi.map((Map<String, dynamic> item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Text(item[
                            'text']), // Display the 'name' field in the dropdown
                      );
                    }).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        _selectedAsuransi = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _beratController,
                decoration: const InputDecoration(
                  labelText: 'Berat',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  helperText: 'Satuan dalam kilogram',
                  helperStyle: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _diskonController,
                decoration: const InputDecoration(
                  labelText: 'Diskon',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  helperText: 'Dalam Persen (%)',
                  helperStyle: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 20),
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
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
