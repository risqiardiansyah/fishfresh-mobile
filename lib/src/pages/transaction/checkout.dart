import 'package:fishfreshapp/src/app.dart';
import 'package:fishfreshapp/src/components/web_view.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishfreshapp/src/model/currency.dart';

class Checkout extends StatefulWidget {
  final dynamic shops;
  final dynamic users;
  final List<dynamic> product;
  const Checkout({super.key, this.shops, this.users, required this.product});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final SessionManager sessionManager = SessionManager();
  List<dynamic> address = [];
  List<dynamic> shipping = [];
  List<dynamic> paymentMethod = [];
  List<dynamic> listProduct = [];
  List<dynamic> fee = [];
  double subtotal = 0;
  double total = 0;
  int qty = 1;

  Map<String, dynamic> _pengiriman = {};
  Map<String, dynamic> _paymentMethod = {};
  Map<String, dynamic> _address = {};

  bool _isLoading = false;

  void initAddress(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.fetchData('alamat', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          address = dataProvider.data['data'];
        });

        if (address.isNotEmpty) {
          setState(() {
            _address = address[0];
          });
        }
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  void initShipping(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.fetchData(
          'shipping/shops?users_shops_id=${widget.shops['users_shops_id']}',
          token: token);

      if (dataProvider.data['success']) {
        setState(() {
          shipping = dataProvider.data['data'];
        });
        print(shipping);
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  void initPaymentMethod(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.fetchData('payment_method', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          paymentMethod = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  void initFee(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.fetchData('platform_fee', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          fee = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      calculateTotal();
    }
  }

  @override
  void initState() {
    super.initState();

    initAddress(context);
    initShipping(context);
    initPaymentMethod(context);
    initFee(context);

    setState(() {
      listProduct = widget.product;
    });

    calculateTotal();
  }

  doBuatPesanan() async {
    setState(() {
      _isLoading = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.postData(
        'orders',
        {
          "product": listProduct,
          "alamat_id": _address['id'],
          "shipping_id": _pengiriman['id'],
          "payment_method_id": _paymentMethod['id']
        },
        token: token,
      );

      if (dataProvider.data['success']) {
        var paymentUrl = dataProvider.data['data']['payment_url'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebView(
              title: 'Pembayaran',
              initialUrl: paymentUrl,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                      setIndex: 2,
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        );
      } else {
        print("failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Order failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Order Failed: ${dataProvider.data['message']}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  handleDecreaseQty(index) {
    var newListProducts = listProduct;

    if (newListProducts[index]['qty'] > 1) {
      newListProducts[index]['qty'] = newListProducts[index]['qty'] - 1;
    }

    setState(() {
      listProduct = newListProducts;
    });

    calculateTotal();
  }

  handleIncreaseQty(index) {
    var newListProducts = listProduct;

    newListProducts[index]['qty'] = newListProducts[index]['qty'] + 1;

    setState(() {
      listProduct = newListProducts;
    });

    calculateTotal();
  }

  calculateTotal() {
    double totalFee = 0;
    double subtotalHarga = 0;

    for (var product in listProduct) {
      subtotalHarga += product['harga_diskon_ori'] * product['qty'];
    }

    print(fee);
    for (var f in fee) {
      totalFee += f['fee'];
    }

    setState(() {
      subtotal = subtotalHarga;
      total = subtotalHarga + totalFee;
    });
  }

  bool isCheckoutDisabled() {
    return _pengiriman.isEmpty ||
        _address.isEmpty ||
        _paymentMethod.isEmpty ||
        listProduct.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rincian Pesanan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alamat Pengiriman
              _buildAddressSection(setState),

              const SizedBox(height: 16),

              // Rincian Pesanan
              _buildProductDetails(),

              const SizedBox(height: 16),

              // Pengiriman
              _buildShippingDetails(setState),

              const SizedBox(height: 16),

              // Metode Pembayaran
              _buildPaymentMethod(setState),

              const SizedBox(height: 16),

              // Info Total Harga
              _buildTotalPaymentInfo(),

              const SizedBox(height: 16),

              // Tombol Buat Pesanan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi buat pesanan
                    isCheckoutDisabled() || _isLoading
                        ? print('handled')
                        : doBuatPesanan();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isCheckoutDisabled() || _isLoading
                        ? Colors.grey
                        : const Color(0xFFff9000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Membuat Pesanan...' : 'Buat Pesanan',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(parentSetState) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFff9000)),
            const SizedBox(width: 16),
            if (_address.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.users['name'] + ' - ' + widget.users['phone'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _address['kota'] + ' - ' + _address['alamat'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Silahkan Pilih Alamat Anda',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return DraggableScrollableSheet(
                          initialChildSize: 0.5, // Set ukuran awal popup
                          minChildSize: 0.3, // Set ukuran minimal
                          maxChildSize: 0.8, // Set ukuran maksimal
                          expand: false,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0)),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Pilih Alamat Tujuan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  const Divider(),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: address.length,
                                      itemBuilder: (context, index) {
                                        final item = address[index];
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.location_on,
                                          ),
                                          title: Text(item['kota'] ?? ''),
                                          subtitle: Text(
                                            item['alamat'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: Radio<String>(
                                            value: item['id'].toString(),
                                            groupValue:
                                                _address['id'].toString(),
                                            onChanged: (value) {
                                              parentSetState(() {
                                                _address = item;
                                              });
                                              setState(() {
                                                _address = item;
                                              });
                                            },
                                          ),
                                          onTap: () {
                                            parentSetState(() {
                                              _address = item;
                                            });
                                            setState(() {
                                              _address = item;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(
                    'assets/images/shop.png',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.shops['shop_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: listProduct.asMap().entries.map((entry) {
                int index = entry.key;
                var product = entry.value;

                return Row(
                  children: [
                    Image.network(
                      product['thumbnail'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default.png',
                          width: 80,
                          height: 80,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['nama_produk'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['berat'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${product['harga_diskon']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${product['harga']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (product['qty'] > 1) {
                                        handleDecreaseQty(index);
                                      }
                                    },
                                  ),
                                  Text('${product['qty']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      handleIncreaseQty(index);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails(StateSetter parentSetState) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Color(0xFFff9000)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pengiriman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.5, // Set ukuran awal popup
                              minChildSize: 0.3, // Set ukuran minimal
                              maxChildSize: 0.8, // Set ukuran maksimal
                              expand: false,
                              builder: (BuildContext context,
                                  ScrollController scrollController) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0)),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 50,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Pilih Pengiriman',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: shipping.length,
                                          itemBuilder: (context, index) {
                                            final item = shipping[index];
                                            return ListTile(
                                              leading: const Icon(
                                                  Icons.local_shipping,
                                                  color: Colors.amber),
                                              title: Text(item['name'] ?? ''),
                                              // subtitle:
                                              //     Text(item['subtitle'] ?? ''),
                                              trailing: Radio<String>(
                                                value: item['id'].toString(),
                                                groupValue: _pengiriman['id']
                                                    .toString(),
                                                onChanged: (value) {
                                                  parentSetState(() {
                                                    _pengiriman = item;
                                                  });
                                                  setState(() {
                                                    _pengiriman = item;
                                                  });
                                                },
                                              ),
                                              onTap: () {
                                                parentSetState(() {
                                                  _pengiriman = item;
                                                });
                                                setState(() {
                                                  _pengiriman = item;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Text('Lihat Semua',
                      style: TextStyle(color: Color(0xFFff9000))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_pengiriman.isNotEmpty)
              Row(
                children: [
                  Text(_pengiriman['name']),
                ],
              )
            else
              const Text(
                'Silahkan Pilih Metode Pengiriman',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(parentSetState) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Color(0xFFff9000)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.5, // Set ukuran awal popup
                              minChildSize: 0.3, // Set ukuran minimal
                              maxChildSize: 0.8, // Set ukuran maksimal
                              expand: false,
                              builder: (BuildContext context,
                                  ScrollController scrollController) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0)),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 50,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Pilih Pengiriman',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: paymentMethod.length,
                                          itemBuilder: (context, index) {
                                            final item = paymentMethod[index];
                                            return ListTile(
                                              leading: Image.network(
                                                item['pm_logo'],
                                                width: 40,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    'assets/images/default.png',
                                                    width: 40,
                                                  );
                                                },
                                              ),
                                              title:
                                                  Text(item['pm_title'] ?? ''),
                                              trailing: Radio<String>(
                                                value: item['id'].toString(),
                                                groupValue: _paymentMethod['id']
                                                    .toString(),
                                                onChanged: (value) {
                                                  parentSetState(() {
                                                    _paymentMethod = item;
                                                  });
                                                  setState(() {
                                                    _paymentMethod = item;
                                                  });
                                                },
                                              ),
                                              onTap: () {
                                                parentSetState(() {
                                                  _paymentMethod = item;
                                                });
                                                setState(() {
                                                  _paymentMethod = item;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Text('Lihat Semua',
                      style: TextStyle(color: Color(0xFFff9000))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_paymentMethod.isNotEmpty)
              Row(
                children: [
                  Image.network(
                    _paymentMethod['pm_logo'],
                    width: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default.png',
                        width: 40,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentMethod['pm_title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              const Text(
                'Silahkan Pilih Metode Pembayaran',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPaymentInfo() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(formatRupiah(subtotal)),
                    ]),
                ...fee.map((item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title']),
                      Text(formatRupiah(item['fee'].toDouble())),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              margin: const EdgeInsets.all(0.0),
              color: const Color.fromARGB(255, 255, 238, 212),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Biaya Pengiriman Akan ditagih ketika pesanan sampai',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formatRupiah(total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
