import 'package:intl/intl.dart';

String rupiah(dynamic nilai) {
  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  return format.format(
    int.tryParse(nilai.toString()) ?? 0,
  );
}