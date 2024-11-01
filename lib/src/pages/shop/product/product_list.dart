import 'package:fishfreshapp/src/components/card_product_shop.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/shop/product/product_add.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final SessionManager sessionManager = SessionManager();

  List<dynamic> product = [];

  @override
  void initState() {
    super.initState();

    initSession(context);
  }

  void initSession(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('product', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          product = dataProvider.data['data'];
        });
      } else {
        print("Login failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during login: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, please try again.")));
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    initSession(context);
  }

  _onDelete(id) {
    showAlertDialog(context, id);
  }

  _doDelete(id) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.postData('product/delete/$id', {}, token: token);

      if (dataProvider.data['success']) {
        setState(() {
          product = dataProvider.data['data'];
        });
      } else {
        print("Failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error : $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed, please try again.")));
    } finally {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  showAlertDialog(BuildContext context, id) {
    // set up the buttons
    Widget cancelButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: const Text(
          "Batal",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
    Widget continueButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: const Text(
          "Ya",
          style: TextStyle(color: Colors.red),
        ),
        onTap: () async {
          await _doDelete(id);

          Navigator.of(context).pop();

          initSession(context);
        },
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Hapus Produk"),
      content: const Text("Anda Yakin ingin menghapus Produk ini ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk Saya"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: product.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: MediaQuery.of(context).size.height - 200,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.newspaper_rounded,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Belum ada produk',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: product.length,
                itemBuilder: (context, index) {
                  final prod = product[index];
                  return CardProductShop(
                    imageUrl: prod['thumbnail'],
                    productName: prod['nama_produk'],
                    jenis: prod['jenis'],
                    berat: prod['berat'],
                    stok: prod['stock'].toString(),
                    oldPrice: prod['harga'],
                    discountPrice: prod['harga_diskon'],
                    discount: prod['diskon'].toString(),
                    deskripsi: prod['deskripsi'],
                    onDelete: () => {
                      _onDelete(prod['id']),
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductAdd()),
          );

          setState(() {
            initSession(context);
          });
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF08244d),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
