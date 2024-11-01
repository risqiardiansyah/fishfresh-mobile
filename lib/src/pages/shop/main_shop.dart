import 'package:fishfreshapp/src/components/button_icon.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/shop/chat/chat_list.dart';
import 'package:fishfreshapp/src/pages/shop/pesanan/pesanan.dart';
import 'package:fishfreshapp/src/pages/shop/product/product_list.dart';
import 'package:fishfreshapp/src/pages/shop/register_shop.dart';
import 'package:fishfreshapp/src/pages/shop/shipping_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fishfreshapp/src/model/currency.dart';

class MainShop extends StatefulWidget {
  const MainShop({super.key});

  @override
  State<MainShop> createState() => _MainShopState();
}

class _MainShopState extends State<MainShop> {
  final SessionManager sessionManager = SessionManager();

  bool _isLoading = false;

  Map<String, dynamic> profile = {
    'hasShops': false,
    'shops': {
      'status': 'unknown',
    }
  };

  Map<String, dynamic> balance = {
    'balance': 0,
  };

  @override
  void initState() {
    super.initState();

    initData(context);
    getBalance(context);
  }

  _launchURL() async {
    final Uri url = Uri.parse('https://fishfresh.id');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void initData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('profile', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          profile = dataProvider.data['data'];
        });

        print(dataProvider.data['data']);
        print(profile['hasShops']);
      } else {
        print("failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during access: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to access, please try again.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getBalance(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('shop/balance', token: token);

      print(dataProvider.data);

      if (dataProvider.data['success']) {
        setState(() {
          balance = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during access: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    initData(context);
    getBalance(context);
  }

  _renderView() {
    if (profile['shops'].isNotEmpty &&
        profile['shops']['status'] == 'request') {
      return requestShops(context);
    } else if (profile['shops'].isNotEmpty &&
        profile['shops']['status'] == 'tidak aktif') {
      return requestFail(context);
    } else if (profile['shops'].isNotEmpty &&
        profile['shops']['status'] == 'aktif') {
      return myShop(context);
    } else if (profile['hasShops'] == false) {
      return noShops(context);
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toko Saya"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading ? loading(context) : _renderView(),
      ),
    );
  }

  Widget noShops(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 500,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.block_flipped,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Anda belum terdaftar sebagai penjual',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daftar sebagai penjual dengan klik tombol dibawah ini',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterShop()),
                      );

                      initData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFFff9000),
                    ),
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget requestShops(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 500,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_outlined,
                  size: 100,
                  color: Color(0xFFff9000),
                ),
                SizedBox(height: 20),
                Text(
                  'Pendaftaran Anda Sedang diproses',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Pendaftaran Anda sebagai penjual sedang kami verifikasi, mohon tunggu dan cek secara berkala',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget requestFail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 500,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.close_rounded,
                  size: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pendaftaran Anda Ditolak',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mohon maaf pendaftaran toko Anda ditolak karena alasan tertentu, silahkan lakukan pengajuan ulang',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterShop(
                            id: 123,
                          ),
                        ),
                      );

                      initData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFFff9000),
                    ),
                    child: const Text(
                      'Ajukan Ulang',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.of(context).size.height - 500,
          ),
          child: const Center(
              child: CircularProgressIndicator(
            color: Color(0xFFff9000),
          )),
        ),
      ),
    );
  }

  Widget myShop(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 20.0),
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/ikan2.png',
                width: 70.0,
                height: 70.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['shops']['shop_name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile['shops']['alamat'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Icon(
                    //   Icons.star,
                    //   size: 16,
                    //   color: Colors.amber,
                    // ),
                    // SizedBox(width: 4),
                    // Text(
                    //   '4,8/5',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 1, color: Colors.grey[300]),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo Penjual',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatRupiah(balance['balance'].toDouble() ?? 0),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      'Hubungi pusat bantuan untuk melakukan penarikan',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
            // const Spacer(),
            // ElevatedButton(
            //   onPressed: () {
            //     // Aksi untuk button Kunjungi
            //   },
            //   style: ElevatedButton.styleFrom(
            //     side: const BorderSide(color: Color(0xFFff9000)),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     'Tarik Saldo',
            //     style: TextStyle(
            //       color: Color(0xFFff9000),
            //     ),
            //   ),
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 1, color: Colors.grey[300]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ButtonIcon(
              title: 'Produk Saya',
              icon: 'assets/images/semua.png',
              from: 'asset',
              width: 35.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductList(),
                  ),
                );
              },
            ),
            ButtonIcon(
              title: 'Pesanan',
              icon: 'assets/images/order.png',
              from: 'asset',
              width: 35.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Pesanan(),
                  ),
                );
              },
            ),
            ButtonIcon(
              title: 'Iklan \n (Segera)',
              icon: 'assets/images/semua.png',
              from: 'asset',
              width: 35.0,
              onPressed: () => {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nantikan fitur ini, segera !!"),
                  ),
                )
              },
            ),
            ButtonIcon(
              title: 'Metode \n Pengiriman',
              icon: 'assets/images/produk.png',
              from: 'asset',
              width: 35.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShippingMethod(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ButtonIcon(
              title: 'Pusat Bantuan',
              icon: 'assets/images/help.png',
              from: 'asset',
              width: 35.0,
              onPressed: () => _launchURL(),
            ),
            const SizedBox(width: 30),
            ButtonIcon(
              title: 'Chat',
              icon: 'assets/images/help.png',
              from: 'asset',
              width: 35.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatList(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
