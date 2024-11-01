import 'package:fishfreshapp/src/model/currency.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/transaction/transaction_item.dart';
import 'package:fishfreshapp/src/pages/transaction/transaksi_riwayat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Transaksi extends StatefulWidget {
  const Transaksi({super.key});

  @override
  State<Transaksi> createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  // int _tabIndex = 0;
  List<dynamic> transactions = [];
  bool isLoadingMore = false;
  String status = 'payment';
  int limit = 10;
  int offset = 0;
  bool eop = true;

  bool _isLoading = false;

  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(_handleTabSelection);
    _scrollController.addListener(_scrollListener);

    getData(context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void getData(BuildContext context) async {
    setState(() {
      isLoadingMore = true;
      _isLoading = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      print('user/transaction?status=$status&limit=$limit&offset=$offset');
      await dataProvider.fetchData(
          'user/transaction?status=$status&limit=$limit&offset=$offset',
          token: token);

      if (dataProvider.data['success'] &&
          dataProvider.data['data'].length > 0) {
        setState(() {
          transactions.addAll(dataProvider.data['data']);
          offset = offset + limit;
          eop = false;
        });
      } else if (dataProvider.data['success'] &&
          dataProvider.data['data'].length <= 0) {
        setState(() {
          offset = offset + limit;
          eop = true;
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during: $error");
    } finally {
      setState(() {
        isLoadingMore = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (!eop) {
      if (isLoadingMore) return;
      setState(() {
        isLoadingMore = true;
      });

      getData(context);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTransactions();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      eop = false;
      limit = 10;
      offset = 0;
      transactions.removeWhere((item) => item.isNotEmpty);
    });
    getData(context);
  }

  _handleTabSelection() {
    var sts = 'payment';
    switch (_tabController.index) {
      case 1:
        sts = 'process';
        break;
      case 2:
        sts = 'send';
        break;
      case 3:
        sts = 'done';
        break;
      case 4:
        sts = 'cancel';
        break;
      default:
    }
    setState(() {
      // _tabIndex = _tabController.index;
      status = sts;
      eop = false;
      limit = 10;
      offset = 0;
      transactions.removeWhere((item) => true);
    });

    getData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFff9000),
          unselectedLabelColor: Colors.black,
          indicatorColor: const Color(0xFFff9000),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Diproses'),
            Tab(text: 'Dikirim'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // List produk untuk tiap tab
          buildTransaksiGrid(),
          buildTransaksiGrid(),
          buildTransaksiGrid(),
          buildTransaksiGrid(),
          buildTransaksiGrid(),
        ],
      ),
    );
  }

  Widget buildTransaksiGrid() {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: _isLoading == true
          ? const Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFFff9000),
                    ),
                  ),
                ],
              ),
            )
          : transactions.isEmpty
              ? const Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text('Data Kosong'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionItem(
                      storeName: transaction['shops']['shop_name'],
                      products: transaction['products'],
                      totalPrice: transaction['total_amount'],
                      status: getStatus(transaction['status']),
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransaksiRiwayat(
                              product: transaction['products'],
                              shipping: transaction['shipping'],
                              address: transaction['address'],
                              paymentMethod: transaction['payment_method'],
                              shops: transaction['shops'],
                              total: formatRupiah(
                                  transaction['total_amount'].toDouble()),
                              subtotal: formatRupiah(
                                  transaction['subtotal'].toDouble()),
                              status: transaction['status'],
                              transactionUrl: transaction['transaction_url'],
                              transactionId: transaction['id'],
                              resiNo: transaction['no_resi'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
