import 'package:dio/dio.dart';
import 'package:penjualan_buku/model/api_response.dart';
import 'package:penjualan_buku/model/barang.dart';
import 'package:penjualan_buku/model/transaksi.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://192.168.68.115:8009';

  Future<List<Barang>> fetchData(String keyword) async {
    Response response =
        await _dio.get('$baseUrl/api.php?action=search&keyword=$keyword');
    List<Barang> data = [];
    for (var item in response.data) {
      data.add(Barang(
        id: item['id'],
        nama: item['nama'],
        harga: item['harga'],
        stok: item['stok'],
        kategori: item['kategori'],
        tanggalMasuk: item['tanggal_masuk'],
      ));
    }
    return data;
  }

  Future<ApiResponse> createData(String nama, int harga, int stok,
      String kategori, String tanggalMasuk) async {
    Response response =
        await _dio.post('$baseUrl/api.php?action=create', data: {
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'tanggal_masuk': tanggalMasuk,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }

  Future<ApiResponse> updateData(int id, String nama, int harga, int stok,
      String kategori, String tanggalMasuk) async {
    Response response =
        await _dio.post('$baseUrl/api.php?action=update', data: {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'tanggal_masuk': tanggalMasuk,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }

  Future<ApiResponse> deleteData(int id) async {
    Response response =
        await _dio.post('$baseUrl/api.php?action=delete', data: {
      'id': id,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }

  Future<List<Transaksi>> fetchTransactions() async {
    Response response = await _dio.get('$baseUrl/api.php?action=transaction');
    List<Transaksi> data = [];

    for (var item in response.data) {
      DateTime tanggalMasuk = DateTime.parse(item['tanggal_masuk']);
      DateTime tanggalDibuat = DateTime.parse(item['tanggal_dibuat']);

      data.add(Transaksi(
        id: item['id'],
        jumlahBeli: item['jumlah_beli'],
        nama: item['nama'],
        harga: item['harga'],
        stok: item['stok'],
        barangId: item['barang_id'],
        kategori: item['kategori'],
        tanggalMasuk: tanggalMasuk,
        tanggalDibuat: tanggalDibuat,
      ));
    }

    return data;
  }

  Future<ApiResponse> createTransaction(int barangId, int jumlahBeli) async {
    Response response =
        await _dio.post('$baseUrl/api.php?action=createTransaction', data: {
      'barangId': barangId,
      'jumlahBeli': jumlahBeli,
    });
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }
}
