import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishfreshapp/src/model/currency.dart';

class PesananDetail extends StatefulWidget {
  final dynamic shops;
  final dynamic address;
  final dynamic paymentMethod;
  final dynamic shipping;
  final String subtotal;
  final String total;
  final String status;
  final String transactionUrl;
  final String? resiNo;
  final List<dynamic> product;
  final int transactionId;
  const PesananDetail({
    super.key,
    this.shops,
    this.address,
    required this.product,
    this.paymentMethod,
    this.shipping,
    required this.subtotal,
    required this.total,
    required this.status,
    required this.transactionUrl,
    required this.transactionId,
    this.resiNo,
  });

  @override
  State<PesananDetail> createState() => _PesananDetailState();
}

class _PesananDetailState extends State<PesananDetail> {
  final SessionManager sessionManager = SessionManager();
  TextEditingController _resiFieldController = TextEditingController();

  dynamic address = [];
  dynamic shipping = [];
  dynamic paymentMethod = [];
  List<dynamic> listProduct = [];
  dynamic shops = [];
  List<dynamic> fee = [];
  String subtotal = '0';
  String total = '0';
  String status = '';
  String transactionUrl = '';
  int transactionId = 0;

  bool _isLoading = false;

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
    }
  }

  @override
  void initState() {
    super.initState();

    initFee(context);

    setState(() {
      listProduct = widget.product;
      shops = widget.shops;
      address = widget.address;
      paymentMethod = widget.paymentMethod;
      shipping = widget.shipping;
      subtotal = widget.subtotal;
      total = widget.total;
      status = widget.status;
      transactionUrl = widget.transactionUrl;
      transactionId = widget.transactionId;
    });
  }

  doTerima(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      if (_resiFieldController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Harap Masukkan No Resi !"),
          ),
        );

        return;
      }

      await dataProvider.postData(
        'shop/trans/update',
        {
          'status': 'send',
          'transaction_id': transactionId,
          'no_resi': _resiFieldController.text
        },
        token: token,
      );

      print(dataProvider.data.toString());

      if (dataProvider.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Transaksi Berhasil Diterima"),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Transaksi Gagal Diterima, silahkan hubungi Admin"),
          ),
        );
      }
    } catch (error) {
      print("Error during: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text("Transaksi Gagal Diterima, silahkan hubungi Admin (005)"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  doCancel(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      await dataProvider.postData(
        'shop/trans/update',
        {
          'status': 'cancel',
          'transaction_id': transactionId,
        },
        token: token,
      );

      print(dataProvider.data.toString());

      if (dataProvider.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi Berhasil Dibatalkan"),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Transaksi Gagal Dibatalkan, silahkan hubungi Admin"),
          ),
        );
      }
    } catch (error) {
      print("Error during: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text("Transaksi Gagal Dibatalkan, silahkan hubungi Admin (005)"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  showAlertDialog(BuildContext context, String title, Widget subtitle, action) {
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
        onTap: action,
        child: const Text(
          "Ya",
          style: TextStyle(color: Colors.orange),
        ),
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title),
      content: subtitle,
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
              const SizedBox(height: 16),
              if (status == 'done')
                Card(
                  margin: const EdgeInsets.all(0.0),
                  color: const Color.fromARGB(255, 224, 255, 212),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Pesanan Telah Selesai',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )
              else if (status == 'send')
                Card(
                  margin: const EdgeInsets.all(0.0),
                  color: const Color.fromARGB(255, 212, 234, 255),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Pesanan sedang dalam perjalanan, menunggu pesanan diterima oleh Pembeli',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )
              else if (status == 'process')
                Card(
                  margin: const EdgeInsets.all(0.0),
                  color: const Color.fromARGB(255, 224, 255, 212),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Pembayaran diterima, menunggu update resi dari Anda',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )
              else if (status == 'cancel')
                Card(
                  margin: const EdgeInsets.all(0.0),
                  color: const Color.fromARGB(255, 255, 212, 212),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Pesanan Telah Dibatalkan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
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

              if (status == 'process')
                // Tombol Proses
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _isLoading
                              ? print('handled')
                              : showAlertDialog(
                                  context,
                                  'Terima Pesanan',
                                  TextField(
                                    controller: _resiFieldController,
                                    decoration: const InputDecoration(
                                        hintText: "Masukan No Resi"),
                                  ),
                                  () => {
                                    Navigator.of(context).pop(),
                                    doTerima(context),
                                  },
                                );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isLoading
                              ? Colors.grey
                              : const Color(0xFFff9000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isLoading ? 'Loading...' : 'Terima & Kirim Pesanan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _isLoading
                              ? print('handled')
                              : showAlertDialog(
                                  context,
                                  'Tolak Pesanan',
                                  const Text(
                                    'Anda yakin ingin menolak pesanan ini ? \nAnda akan dikenakan poin pinalti',
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  () => {
                                    Navigator.of(context).pop(),
                                    doCancel(context)
                                  },
                                );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(
                            width: 2.0,
                            color: Colors.grey,
                          ),
                        ),
                        child: Text(
                          _isLoading ? 'Loading...' : 'Tolak Pesanan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
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
            if (address.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address['kota'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      address['alamat'],
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
                      '-',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
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
            const Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFFff9000)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pengiriman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (shipping.isNotEmpty)
              Column(
                children: [
                  Text(shipping['name']),
                  const SizedBox(height: 6),
                  if ((status == 'send' || status == 'done') &&
                      widget.resiNo!.isNotEmpty)
                    Text(
                      'No Resi : ${widget.resiNo}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              )
            else
              const Text(
                '-',
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
            const Row(
              children: [
                Icon(Icons.payment, color: Color(0xFFff9000)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (paymentMethod.isNotEmpty)
              Row(
                children: [
                  Image.network(
                    paymentMethod['pm_logo'],
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
                      paymentMethod['pm_title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              const Text(
                '-',
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
                      Text(subtotal),
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
                  total,
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
