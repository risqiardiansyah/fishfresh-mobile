import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/address/address_add.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final SessionManager sessionManager = SessionManager();

  List<dynamic> address = [];

  @override
  void initState() {
    super.initState();

    initSession(context);
  }

  void initSession(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('alamat', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          address = dataProvider.data['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alamat Saya"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: address.isEmpty
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
                          Icons.location_off_outlined,
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
                itemCount: address.length,
                itemBuilder: (context, index) {
                  final addr = address[index];
                  return ListItem(
                    icon: Icons.location_on_outlined,
                    kota: addr['kota'] ?? '-',
                    alamat: addr['alamat'] ?? '-',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressAddPage(
                            id: addr['id'],
                            alamat: addr['alamat'],
                            kota: addr['kota'],
                            alamatToko: addr['alamat_toko'],
                          ),
                        ),
                      );

                      setState(() {
                        initSession(context);
                      });
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressAddPage()),
          );

          setState(() {
            initSession(context);
          });
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF08244d),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final IconData icon;
  final String? kota;
  final String? alamat;
  final VoidCallback onTap;

  const ListItem({
    super.key,
    required this.icon,
    this.kota,
    this.alamat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        kota ?? '-',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        alamat ?? '',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.edit, size: 16),
      onTap: onTap,
    );
  }
}
