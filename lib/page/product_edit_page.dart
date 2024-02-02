import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penjualan_buku/model/api_response.dart';
import 'package:penjualan_buku/model/barang.dart';
import 'package:penjualan_buku/service.dart';

class ProductEditPage extends StatefulWidget {
  const ProductEditPage(this.item, {Key? key}) : super(key: key);

  final Barang item;

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _controllerNama;
  late TextEditingController _controllerHarga;
  late TextEditingController _controllerStok;
  late TextEditingController _controllerKategori;
  DateTime? _selectedDate; // Variabel untuk menyimpan tanggal yang dipilih
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final ApiService _apiService = ApiService();
  @override
  void initState() {
    super.initState();
    _controllerNama = TextEditingController(text: widget.item.nama);
    _controllerHarga =
        TextEditingController(text: widget.item.harga.toString());
    _controllerStok = TextEditingController(text: widget.item.stok.toString());
    _controllerKategori = TextEditingController(text: widget.item.kategori);
    _selectedDate = DateTime.parse(widget.item.tanggalMasuk);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        actions: [
          IconButton(
            onPressed: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah kamu yakin ingin manghapusnya?'),
                  actions: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        _deleteBarang();
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
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
                        suffixIcon: Icon(Icons.calendar_today)),
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
    final ApiResponse result = await _apiService.updateData(
        widget.item.id, nama, harga, stok, kategori, tanggalMasuk);

    if (result.success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil diupdate'),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal update barang.'),
          ),
        );
      }
    }
  }

  Future<void> _deleteBarang() async {
    final ApiResponse result = await _apiService.deleteData(widget.item.id);

    if (result.success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil diupdate'),
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        Navigator.pop(context, true);
        showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(result.message),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
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
