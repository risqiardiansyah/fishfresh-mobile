import 'dart:convert';

import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class EducationAddPage extends StatefulWidget {
  final int? id;
  const EducationAddPage({super.key, this.id});

  @override
  State<EducationAddPage> createState() => _EducationAddPageState();
}

class _EducationAddPageState extends State<EducationAddPage> {
  final SessionManager sessionManager = SessionManager();
  File? _image;
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  String _imageBase64 = '';

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _imageBase64 = 'data:image/png;base64,$base64Image';
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
        'education/add',
        {
          'id': widget.id,
          'title': _titleController.text,
          'link': _linkController.text,
          'image': _imageBase64,
        },
        token: token,
      );

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
        title: const Text('Tambah Fish Education'),
        centerTitle: true,
        backgroundColor: const Color(0xFFff9000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        color: Colors.grey[700],
                        size: 100,
                      )
                    : Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Title input
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // Link input
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Link',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _isLoading ? print('handled') : _simpan(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16), // Tinggi tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor:
                      _isLoading ? Colors.grey : const Color(0xFFff9000),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
