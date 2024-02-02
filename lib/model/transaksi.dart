class Transaksi {
  int id;
  int jumlahBeli;
  String nama;
  int harga;
  int stok;
  int barangId;
  String kategori;
  DateTime tanggalMasuk;
  DateTime tanggalDibuat;

  Transaksi({
    required this.id,
    required this.jumlahBeli,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.barangId,
    required this.kategori,
    required this.tanggalMasuk,
    required this.tanggalDibuat,
  });
}
