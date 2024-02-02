import 'package:flutter/material.dart';
import 'package:penjualan_buku/model/api_response.dart';
import 'package:penjualan_buku/model/barang.dart';
import 'package:penjualan_buku/service.dart';

class TransactionAddPage extends StatefulWidget {
  const TransactionAddPage({Key? key}) : super(key: key);

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage> {
  List<Barang> barangList = [];

  Barang selectedBarang = Barang(
      id: 0, nama: '', harga: 0, stok: 0, kategori: '', tanggalMasuk: '');
  String quantity = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    fetchDataBarang();
    super.initState();
  }

  Future<void> fetchDataBarang() async {
    List<Barang> data = await _apiService.fetchData('');
    setState(() {
      barangList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Barang>(
                decoration: buildInputDecoration('Select Product'),
                value: selectedBarang.id == 0 ? null : selectedBarang,
                onChanged: (Barang? newValue) {
                  setState(() {
                    selectedBarang = newValue!;
                  });
                },
                items:
                    barangList.map<DropdownMenuItem<Barang>>((Barang barang) {
                  return DropdownMenuItem<Barang>(
                    value: barang,
                    child: Text("${barang.nama} - Stok: ${barang.stok}"),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.id == 0) {
                    return 'Please select a product';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration('Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  int enteredQuantity = int.tryParse(value) ?? 0;
                  if (enteredQuantity <= 0) {
                    return 'Quantity must be greater than zero';
                  }
                  if (enteredQuantity > selectedBarang.stok) {
                    return 'Quantity exceeds available stock';
                  }
                  return null;
                },
                onChanged: (value) {
                  quantity = value;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _createTransaction();
    }
  }

  Future<void> _createTransaction() async {
    // Example create barang
    final int barangId = selectedBarang.id;
    int jumlahBeli = 0;

    if (quantity == '') {
      jumlahBeli = 0;
    } else {
      jumlahBeli = int.parse(quantity);
    }

    // Implementasi fungsi createData dari ApiService
    final ApiResponse result =
        await _apiService.createTransaction(barangId, jumlahBeli);

    if (result.success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dibuat'),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat Transaksi.'),
          ),
        );
      }
    }
  }

  InputDecoration buildInputDecoration(String labelText, {Icon? suffixIcon}) {
    return InputDecoration(
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
      label: Text(labelText),
      suffixIcon: (suffixIcon != null) ? suffixIcon : null,
      errorMaxLines: 3,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
