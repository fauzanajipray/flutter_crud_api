import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penjualan_buku/model/transaksi.dart';

class TransactionViewPage extends StatefulWidget {
  const TransactionViewPage(this.item, {Key? key}) : super(key: key);

  final Transaksi item;

  @override
  State<TransactionViewPage> createState() => _TransactionViewPageState();
}

class _TransactionViewPageState extends State<TransactionViewPage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID : ${widget.item.id}'),
            const SizedBox(height: 8),
            Text('Product Name : ${widget.item.nama}'),
            const SizedBox(height: 8),
            Text('Quantity : ${widget.item.jumlahBeli}'),
            const SizedBox(height: 8),
            Text('Price : ${widget.item.harga}'),
            const SizedBox(height: 8),
            Text('Total : ${widget.item.jumlahBeli * widget.item.harga}'),
            const SizedBox(height: 8),
            Text('Category: ${widget.item.kategori}'),
            const SizedBox(height: 8),
            Text(
                'Transaction Date: ${_dateFormat.format(widget.item.tanggalDibuat)}'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DataRowCustom extends StatelessWidget {
  const DataRowCustom(
    this.value, {
    super.key,
  });

  final DataValueCustom value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: value.leftValue,
          ),
          if (value.rightValue != null)
            Align(
              alignment: Alignment.centerRight,
              child: value.rightValue,
            ),
        ],
      ),
    );
  }
}

class DataValueCustom {
  final Widget leftValue;
  final Widget? rightValue;

  DataValueCustom({required this.leftValue, required this.rightValue});
}
