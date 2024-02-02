import 'package:flutter/material.dart';
import 'package:penjualan_buku/helper.dart';
import 'package:penjualan_buku/model/barang.dart';
import 'package:penjualan_buku/page/product_add_page.dart';
import 'package:penjualan_buku/page/product_edit_page.dart';
import 'package:penjualan_buku/service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  List<Barang> _barangList = [];
  final ApiService _apiService = ApiService();
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _fetchData(keyword);
  }

  Future<void> _fetchData(String keyword) async {
    List<Barang> data = await _apiService.fetchData(keyword);
    setState(() {
      _barangList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Barang'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          bool? reload = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductAddPage()),
          );
          if (reload == true) {
            _fetchData(keyword);
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _fetchData(keyword),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 8),
              child: TextFormField(
                controller: _controllerSearch,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  filled: true,
                  hintText: 'Search...',
                  // errorText: widget.errorText,
                  errorMaxLines: 3,
                  suffixIcon: const Icon(Icons.search),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                  });
                },
                onEditingComplete: () {
                  _fetchData(keyword);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _barangList.length,
                itemBuilder: (context, index) {
                  Barang item = _barangList[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item.nama),
                        subtitle: Text("Rp. ${formatCurrency(item.harga)}"),
                        trailing: const Icon(Icons.edit),
                        minVerticalPadding: 5,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        onTap: () async {
                          bool? reload = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductEditPage(item),
                            ),
                          );
                          if (reload == true) {
                            _fetchData(keyword);
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Divider(height: 1),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
