import 'package:fishfreshapp/src/components/card_product.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/product/details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  final String keyword;
  const SearchPage({super.key, required this.keyword});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final SessionManager sessionManager = SessionManager();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _productList = [];
  String myToken = '';
  bool _isLoading = false;
  int limit = 10;
  int offset = 0;
  bool eop = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    initData(context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void initData(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    if (token != null) {
      setState(() {
        myToken = token;
      });
    }

    try {
      var endpoint =
          'sell/product?search=${widget.keyword}&limit=$limit&offset=$offset';
      await dataProvider.fetchData(endpoint, token: token);

      if (dataProvider.data['success'] &&
          dataProvider.data['data'].length > 0) {
        setState(() {
          _productList.addAll(dataProvider.data['data']);
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
        print("Login failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (!eop) {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });

      initData(context);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      limit = 10;
      offset = 0;
      _productList.removeWhere((item) => item != null);
    });
    initData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pencarian'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _productList.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: MediaQuery.of(context).size.height - 200,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.grid_off_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Produk Tidak Ditemukan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Keyword : ${widget.keyword}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView(
                controller: _scrollController,
                padding:
                    const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hasil pencarian untuk ${widget.keyword}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.28,
                    ),
                    itemCount: _productList.length,
                    itemBuilder: (context, index) {
                      final dynamic product = _productList[index];
                      return CardProduct(
                        title: product['nama_produk'],
                        image: product['thumbnail'],
                        discount: product['diskon'],
                        priceNormal: product['harga'],
                        priceAfterDiscount: product['harga_diskon'],
                        sold: product['sold'].toString(),
                        rating: product['rating'].toString(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(
                                product: product,
                                images: product['images'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (_isLoading)
                    const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFFff9000),
                          ),
                        ),
                      ],
                    ),
                  if (eop)
                    const Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tidak ada lagi produk',
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
