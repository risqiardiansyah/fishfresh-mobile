import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShippingMethod extends StatefulWidget {
  const ShippingMethod({super.key});

  @override
  State<ShippingMethod> createState() => _ShippingMethodState();
}

class _ShippingMethodState extends State<ShippingMethod> {
  final SessionManager sessionManager = SessionManager();

  List<dynamic> shipping = [];
  bool canSave = false;

  @override
  void initState() {
    super.initState();

    initSession(context);
  }

  void initSession(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('shipping', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          shipping = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during  $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("failed, please try again.")));
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  void doSave(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.postData('shipping/save', {'data': shipping},
          token: token);

      if (dataProvider.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Metode Pengiriman Disimpan"),
          backgroundColor: Colors.green,
        ));
      } else {
        print("failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during  $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("failed, please try again.")));
    } finally {
      setState(() {
        canSave = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    initSession(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Metode Pengiriman Saya"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: shipping.isEmpty
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
                          Icons.local_shipping,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Belum ada alamat',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: shipping.length,
                itemBuilder: (context, index) {
                  final ship = shipping[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.local_shipping, color: Colors.black),
                    title: Text(
                      ship['name'] ?? '-',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      ship['need_resi'] == 0
                          ? 'Butuh Resi'
                          : 'Tidak Butuh Resi',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Checkbox(
                      activeColor: const Color(0xFFff9000),
                      value: ship["selected"],
                      onChanged: (bool? value) {
                        setState(() {
                          shipping[index]['selected'] = value;
                          canSave = true;
                        });

                        print(shipping);
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            canSave ? doSave(context) : print('handled');
          },
          foregroundColor: Colors.white,
          backgroundColor: canSave ? const Color(0xFFff9000) : Colors.grey,
          shape: const CircleBorder(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save),
              Text(
                'Simpan',
                style: TextStyle(fontSize: 9.0),
              )
            ],
          )),
    );
  }
}
