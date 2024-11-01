import 'package:fishfreshapp/src/model/currency.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String storeName;
  final List<dynamic> products;
  final int totalPrice;
  final String status;
  final VoidCallback onClick;

  const TransactionItem({
    super.key,
    required this.storeName,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Products
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: products.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product['nama_produk']} (x${product['qty']})',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formatRupiah(product['total_price'].toDouble()),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatRupiah(totalPrice.toDouble()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
