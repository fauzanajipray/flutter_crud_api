import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penjualan_buku/helper.dart';
import 'package:penjualan_buku/model/transaksi.dart';
import 'package:penjualan_buku/page/transaction_add_page.dart';
import 'package:penjualan_buku/page/transaction_view_page.dart';
import 'package:penjualan_buku/service.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  List<Transaksi> _transaksiList = [];
  final ApiService _apiService = ApiService();
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<Transaksi> data = await _apiService.fetchTransactions();
    setState(() {
      _transaksiList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Transaksi'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransactionAddPage()),
          );
        },
      ),
      body: RefreshIndicator(
          onRefresh: () => Future.sync(
                () => _fetchData(),
              ),
          child: ListView.builder(
            itemCount: _transaksiList.length,
            itemBuilder: (context, index) {
              Transaksi item = _transaksiList[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(item.nama),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text("Rp. ${formatCurrency(item.harga)}"),
                        const SizedBox(height: 6),
                        Text(DateFormat('yyyy-MM-dd')
                            .format(item.tanggalDibuat)),
                      ],
                    ),
                    trailing: const Icon(Icons.remove_red_eye),
                    // minVerticalPadding: 5,
                    // contentPadding:
                    //     const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionViewPage(item),
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Divider(height: 1),
                  )
                ],
              );
            },
          )),
    );
  }
}
