import 'package:flutter/material.dart';
import 'package:penjualan_buku/page/product_page.dart';
import 'package:penjualan_buku/page/transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ProductPage(),
    const TransactionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'List Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List Transaksi',
          ),
        ],
      ),
    );
  }
}
