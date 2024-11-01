import 'package:carousel_slider/carousel_slider.dart';
import 'package:fishfreshapp/src/app.dart';
import 'package:fishfreshapp/src/components/button_icon.dart';
import 'package:fishfreshapp/src/components/card_product.dart';
import 'package:fishfreshapp/src/components/slide_right.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/auth/login.dart';
import 'package:fishfreshapp/src/pages/product/details.dart';
import 'package:fishfreshapp/src/pages/product/search.dart';
import 'package:fishfreshapp/src/pages/shop/main_shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final SessionManager sessionManager = SessionManager();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _productList = [];
  List<dynamic> _bannerList = [];
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
    initBanner(context);
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
      var endpoint = 'sell/product?limit=$limit&offset=$offset';
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

  void initBanner(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('slider', token: token);
      print(dataProvider.data);
      if (dataProvider.data['success']) {
        setState(() {
          _bannerList = dataProvider.data['data'];
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
    initBanner(context);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: _bannerList.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(
                    item,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/banner.png',
                      );
                    },
                  );
                },
              );
            }).toList(),
          ),

          // Icon Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonIcon(
                  title: 'Area Investor',
                  icon: 'assets/images/investor.png',
                  from: 'asset',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Comming Soon !")));
                  },
                ),
                ButtonIcon(
                  title: 'Area Penjual',
                  icon: 'assets/images/penjual.png',
                  from: 'asset',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => myToken.isEmpty
                            ? const LoginPage()
                            : const MainShop(),
                      ),
                    );
                  },
                ),
                ButtonIcon(
                    title: 'Produk Pilihan',
                    icon: 'assets/images/produk.png',
                    from: 'asset',
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideRightRoute(
                          page: const SearchPage(keyword: 'Produk Pilihan'),
                        ),
                      );
                    }),
                ButtonIcon(
                  title: 'Education',
                  icon: 'assets/images/semua.png',
                  from: 'asset',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(
                          setIndex: 1,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // Produk Pilihan
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anda Mungkin Suka',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
