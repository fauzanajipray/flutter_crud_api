import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penjualan_buku/model/api_response.dart';
import 'package:penjualan_buku/service.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({Key? key}) : super(key: key);

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerNama = TextEditingController();
  final TextEditingController _controllerHarga = TextEditingController();
  final TextEditingController _controllerStok = TextEditingController();
  final TextEditingController _controllerKategori = TextEditingController();
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controllerNama,
                decoration: buildInputDecoration('Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllerHarga,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration('Harga'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  // Validasi apakah input adalah angka
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllerStok,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration('Stok'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  // Validasi apakah input adalah angka
                  if (int.tryParse(value) == null) {
                    return 'Stok harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllerKategori,
                decoration: buildInputDecoration('Kategori'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? _dateFormat.format(_selectedDate!)
                          : '',
                    ),
                    decoration: buildInputDecoration('Tanggal Masuk',
                        suffixIcon: const Icon(Icons.calendar_today)),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Tanggal Masuk tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text('Simpan'),
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
      _createBarang();
    }
  }

  Future<void> _createBarang() async {
    final String nama = _controllerNama.text;
    final int harga = int.parse(_controllerHarga.text);
    final int stok = int.parse(_controllerStok.text);
    final String kategori = _controllerKategori.text;

    // Format tanggal menggunakan DateFormat
    final String tanggalMasuk = _dateFormat.format(_selectedDate!);

    // Implementasi fungsi createData dari ApiService
    final ApiResponse result =
        await _apiService.createData(nama, harga, stok, kategori, tanggalMasuk);

    if (result.success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil dibuat'),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat barang.'),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
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
