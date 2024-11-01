import 'dart:convert';

import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/auth/login.dart';
import 'package:fishfreshapp/src/pages/chat.dart';
import 'package:fishfreshapp/src/pages/transaction/checkout.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Details extends StatefulWidget {
  final dynamic product;
  final List<dynamic> images;
  const Details({super.key, this.product, required this.images});

  static const routeName = '/product/detail';

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> with SingleTickerProviderStateMixin {
  final SessionManager sessionManager = SessionManager();
  int _currentIndex = 0;
  dynamic users;
  String token = '';

  @override
  void initState() {
    super.initState();

    initData();
  }

  initData() async {
    var savedToken = await sessionManager.getSession('token');
    var getuser = await sessionManager.getSession('user');

    if (savedToken != null) {
      setState(() {
        token = savedToken;
      });
    }

    if (getuser != null) {
      setState(() {
        users = jsonDecode(getuser);
      });
    } else {
      setState(() {
        users = {'id': 'xx'};
      });
    }

    widget.product['qty'] = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Detail Produk'),
            // GestureDetector(
            //   onTap: () {
            //     print('Container tapped!');
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(13.0),
            //     child: Stack(
            //       children: [
            //         const Icon(
            //           Icons.shopping_bag_outlined,
            //           color: Colors.black,
            //           size: 35,
            //         ),
            //         Positioned(
            //           right: 0,
            //           top: 0,
            //           child: Container(
            //             width: 18,
            //             height: 18,
            //             decoration: const BoxDecoration(
            //               color: Color(0xFF09409C),
            //               shape: BoxShape.circle,
            //             ),
            //             child: const Center(
            //               child: Text(
            //                 '10',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 12, // Ukuran teks
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: widget.images.map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.5),
                                    insetPadding: const EdgeInsets.all(
                                      16.0,
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Container(
                                            color: Colors.black,
                                            child: Image.network(
                                              item['img'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 10.0,
                                          top: 10.0,
                                          child: IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Menutup dialog
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                item['img'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default.png',
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        color: Colors.black54,
                        child: Text(
                          '${_currentIndex + 1}/${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian harga dan diskon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.product['harga_diskon'] ?? 'Rp 0',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            widget.product['diskon'] > 0
                                ? Text(
                                    widget.product['harga'] ?? 'Rp 0',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(width: 8),
                        widget.product['diskon'] > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF09409C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${widget.product['diskon']}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),

                    // Nama produk
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.product['nama_produk'] ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Terjual dan rating produk
                    Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terjual ${widget.product['sold'].toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.product['rating'] ?? '0',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const Text(
                        //   ' (69)',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(thickness: 1, color: Colors.grey[300]),
                    ),

                    // Toko dan rating
                    Row(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.orange,
                              width: 2.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/shop.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product['shops']['shop_name'] ?? 'Rp 0',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product['shops']['shop_location'] ??
                                      'Rp 0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product['shops']['shop_rating'] ??
                                      '0.0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Aksi untuk button Kunjungi
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     side: const BorderSide(color: Colors.blueGrey),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     'Kunjungi',
                        //     style: TextStyle(
                        //       color: Colors.blueGrey,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Divider(thickness: 1, color: Colors.grey[300]),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Ikan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['jenis'] ?? 'Rp 0',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Asuransi Produk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['asuransi'] == 'Y' ? 'Ya' : 'Tidak',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Berat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['berat'] ?? '1 kg',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['deskripsi'] ?? '-',
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Divider(thickness: 1, color: Colors.grey[300]),
              ),
            ],
          ),
          // Card with fixed position at the bottom of the screen
          if (users != null &&
              widget.product['shops']['user_id'] != users['id'])
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 4,
                child: Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                idTo: widget.product['shops']['users_shops_id'],
                                nameTo: widget.product['shops']['shop_name'],
                                isShop: false,
                              ),
                            ),
                          )
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_outlined,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Container(
                      //   padding: const EdgeInsets.all(10.0),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(
                      //       color: const Color(0xFF09409C),
                      //       width: 2.0,
                      //     ),
                      //   ),
                      //   child: const Icon(
                      //     Icons.shopping_bag_outlined,
                      //     color: Color(0xFF09409C),
                      //     size: 25,
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      // Tombol Beli Sekarang
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => token.isEmpty
                                    ? const LoginPage()
                                    : Checkout(
                                        shops: widget.product['shops'],
                                        users: users,
                                        product: [widget.product],
                                      ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Warna tombol
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Sudut membulat
                            ),
                          ),
                          child: const SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Text(
                                'Beli Sekarang',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
