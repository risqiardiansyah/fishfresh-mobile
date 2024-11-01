import 'package:flutter/material.dart';

class CardProductShop extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String jenis;
  final dynamic oldPrice;
  final dynamic discountPrice;
  final String stok;
  final String berat;
  final String? discount;
  final String deskripsi;
  final VoidCallback onDelete;

  const CardProductShop({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.jenis,
    required this.oldPrice,
    required this.discountPrice,
    required this.stok,
    required this.berat,
    this.discount,
    required this.deskripsi,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Gambar produk
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/default.png',
                  height: 120.0,
                  width: 120,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Detail produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 20.0,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 3),
                Text(
                  jenis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Berat: $berat',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(
                        Icons.circle,
                        color: Colors.grey,
                        size: 5.0,
                      ),
                    ),
                    Text(
                      'Stok: $stok',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  deskripsi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Harga produk
                Row(
                  children: [
                    // Harga lama
                    discount != null && discount != '0'
                        ? Text(
                            'Rp $oldPrice',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          )
                        : const SizedBox.shrink(),
                    discount != null && discount != '0'
                        ? const SizedBox(width: 8)
                        : const SizedBox.shrink(),

                    // Harga diskon
                    Text(
                      'Rp $discountPrice',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFff9000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
    );
  }
}
