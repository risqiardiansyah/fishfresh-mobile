import 'package:flutter/material.dart';

class CardProduct extends StatelessWidget {
  final String title;
  final String image;
  final int discount;
  final String priceNormal;
  final String priceAfterDiscount;
  final String sold;
  final String rating;
  final VoidCallback? onPressed;

  const CardProduct({
    super.key,
    required this.title,
    required this.image,
    required this.discount,
    required this.priceNormal,
    required this.priceAfterDiscount,
    required this.sold,
    required this.rating,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    // Gambar produk
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0)),
                      child: Image.network(
                        image,
                        height: 125.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default.png',
                            height: 125.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    // Rating bintang di kiri atas gambar
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: rating != '0.0'
                            ? Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.orange, size: 16.0),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    rating,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                // Spasi
                const SizedBox(height: 8.0),
                // Nama produk
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Harga dan Diskon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      // Persentase diskon
                      discount > 0
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    '$discount%',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12.0),
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  priceNormal,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 20.0,
                            ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Harga setelah diskon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        priceAfterDiscount,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Harga setelah diskon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '$sold Terjual',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
