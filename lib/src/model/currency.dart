import 'package:intl/intl.dart';

String formatRupiah(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String getStatus(String status) {
  switch (status) {
    case 'payment':
      return 'Belum Bayar';
    case 'process':
      return 'Diproses';
    case 'send':
      return 'Sedang Dikirim';
    case 'done':
      return 'Selesai';
    case 'cancel':
      return 'Dibatalkan';
    default:
      return '-';
  }
}
