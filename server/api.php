<?php
header('Content-Type: application/json');
$servername = "localhost";
$username = "root"; // Ganti dengan username MySQL Anda
$password = "root"; // Ganti dengan password MySQL Anda
$dbname = "project_penjualan"; // Ganti dengan nama database Anda

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fungsi Create
function createData($nama, $harga, $stok, $kategori, $tanggal_masuk)
{
    global $conn;
    $input_data = file_get_contents("php://input");
    $data = json_decode($input_data, true); // true to get an associative array

    // Now you can access the data using $data
    $nama = $nama ?? $data['nama'];
    $harga = $harga ?? $data['harga'];
    $stok = $stok ?? $data['stok'];
    $kategori = $kategori ?? $data['kategori'];
    $tanggal_masuk = $tanggal_masuk ?? $data['tanggal_masuk'];
    $sql = $conn->prepare("INSERT INTO barang (nama, harga, stok, kategori, tanggal_masuk) VALUES (?, ?, ?, ?, ?)");
    $sql->bind_param("siiss", $nama, $harga, $stok, $kategori, $tanggal_masuk);

    if ($sql->execute()) {
        return ['success' => true, 'message' => 'Barang berhasil dibuat'];
    } else {
       
        return ['success' => false, 'message' => $conn->error];
    }
}

// Fungsi Read
function readData($id, $keyword)
{
    global $conn;
    if ($id != null) {
        $sql = "SELECT * FROM barang WHERE id = $id";
        $result = $conn->query($sql);
        $data = $result->fetch_assoc();
        if (!$data) {
            http_response_code(404);
            return ['message' => 'Data tidak ditemukan'];
        } else {
            $data['id'] = (int)$data['id'];
            $data['harga'] = (int)$data['harga'];
            $data['stok'] = (int)$data['stok'];
            return $data;
        }
    } else if ($keyword != null) {
        $sql = "SELECT * FROM barang WHERE nama LIKE '%$keyword%' OR kategori LIKE '%$keyword%'";
        $result = $conn->query($sql);
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $row['id'] = (int)$row['id'];
            $row['harga'] = (int)$row['harga'];
            $row['stok'] = (int)$row['stok'];
            $data[] = $row;
        }
        return $data;
    } else {
        $sql = "SELECT * FROM barang";
        $result = $conn->query($sql);
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $row['id'] = (int)$row['id'];
            $row['harga'] = (int)$row['harga'];
            $row['stok'] = (int)$row['stok'];
            $data[] = $row;
        }
        return $data;
    }
}

// Fungsi Update
function updateData($id, $nama, $harga, $stok, $kategori, $tanggal_masuk)
{
    global $conn;

    $input_data = file_get_contents("php://input");
    $data = json_decode($input_data, true); 

    $id = $id ?? $data['id'];
    $nama = $nama ?? $data['nama'];
    $harga = $harga ?? $data['harga'];
    $stok = $stok ?? $data['stok'];
    $kategori = $kategori ?? $data['kategori'];
    $tanggal_masuk = $tanggal_masuk ?? $data['tanggal_masuk'];
    
    $sql = $conn->prepare("UPDATE barang SET nama=?, harga=?, stok=?, kategori=?, tanggal_masuk=? WHERE id=?");
    $sql->bind_param("siissi", $nama, $harga, $stok, $kategori, $tanggal_masuk, $id);

    if ($sql->execute()) {
        return ['success' => true, 'message' => 'Barang berhasil diupdate'];
    } else {
       
        return ['success' => false, 'message' => $conn->error];
    }
}

// Fungsi Delete
function deleteData($id)
{
    global $conn;

    $input_data = file_get_contents("php://input");
    $data = json_decode($input_data, true);
    $id = $id ?? $data['id'];

    // Check if $id is null
    if ($id === null || $id === '') {
       
        return ['success' => false, 'message' => 'ID cannot be null for deletion.'];
    }

    // Check if there are associated records in transaksi
    $sqlCheckTransaksi = $conn->prepare("SELECT COUNT(*) as count FROM transaksi WHERE barang_id = ?");
    if (!$sqlCheckTransaksi) {
       
        return ['success' => false, 'message' => 'Failed to prepare SQL statement: ' . $conn->error];
    }
    $sqlCheckTransaksi->bind_param("i", $id);
    if (!$sqlCheckTransaksi->execute()) {
       
        return ['success' => false, 'message' => 'Failed to execute SQL statement: ' . $sqlCheckTransaksi->error];
    }

    $result = $sqlCheckTransaksi->get_result();
    $row = $result->fetch_assoc();
    $count = (int)$row['count'];

    if ($count > 0) {
       
        return ['success' => false, 'message' => 'Cannot delete the record. Associated records found in transaksi table.'];
    }

    // If no associated records and $id is not null, proceed with deletion
    $sqlDeleteBarang = $conn->prepare("DELETE FROM barang WHERE id = ?");
    if (!$sqlDeleteBarang) {
       
        return ['success' => false, 'message' => 'Failed to prepare SQL statement: ' . $conn->error];
    }
    $sqlDeleteBarang->bind_param("i", $id);
    if (!$sqlDeleteBarang->execute()) {
       
        return ['success' => false, 'message' => 'Failed to execute SQL statement: ' . $sqlDeleteBarang->error];
    }

    return ['success' => true, 'message' => 'Record deleted successfully.'];
}

// Fungsi Pencarian
function searchByKeyword($keyword)
{
    global $conn;
    $sql = "SELECT * FROM barang WHERE nama LIKE '%$keyword%' OR kategori LIKE '%$keyword%'";
    $result = $conn->query($sql);
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    return $data;
}

// Fungsi Create Transaction
function createTransaction($barangId, $jumlahBeli)
{
    global $conn;

    $input_data = file_get_contents("php://input");
    $data = json_decode($input_data, true); 

    $barangId = $barangId ?? $data['barangId'];
    $jumlahBeli = $jumlahBeli ?? $data['jumlahBeli'];
    $tanggalDibuat = date('Y-m-d');

    // Begin a transaction
    $conn->begin_transaction();

    try {
        // Insert into transaksi table
        $sqlTransaksi = $conn->prepare("INSERT INTO transaksi (barang_id, jumlah_beli, tanggal_dibuat) VALUES (?, ?, ?)");
        if (!$sqlTransaksi) {
            throw new Exception('Failed to prepare SQL statement: ' . $conn->error);
        }
        $sqlTransaksi->bind_param("iis", $barangId, $jumlahBeli, $tanggalDibuat);
        if (!$sqlTransaksi->execute()) {
            throw new Exception('Failed to execute SQL statement: ' . $sqlTransaksi->error);
        }

        // Update stok in barang table
        $sqlUpdateStok = $conn->prepare("UPDATE barang SET stok = stok - ? WHERE id = ?");
        if (!$sqlUpdateStok) {
            throw new Exception('Failed to prepare SQL statement: ' . $conn->error);
        }
        $sqlUpdateStok->bind_param("ii", $jumlahBeli, $barangId);
        if (!$sqlUpdateStok->execute()) {
            throw new Exception('Failed to execute SQL statement: ' . $sqlUpdateStok->error);
        }

        // Commit the transaction
        $conn->commit();

        return ['success' => true, 'message' => 'Transaksi berhasil dibuat'];
    } catch (Exception $e) {
        // Rollback the transaction on error
        $conn->rollback();

        return ['success' => false, 'message' => $e->getMessage()];
    }
}

function readDataTransaction()
{
    global $conn;

    $sql = "SELECT transaksi.id, transaksi.jumlah_beli, transaksi.barang_id, barang.nama, barang.harga, barang.stok, barang.kategori, barang.tanggal_masuk, transaksi.tanggal_dibuat
            FROM transaksi
            INNER JOIN barang ON transaksi.barang_id = barang.id";

    $result = $conn->query($sql);

    if ($result) {
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $row['id'] = (int)$row['id'];
            $row['harga'] = (int)$row['harga'];
            $row['barang_id'] = (int)$row['barang_id'];
            $row['stok'] = (int)$row['stok'];
            $row['jumlah_beli'] = (int)$row['jumlah_beli'];
            $data[] = $row;
        }
        return $data;
    } else {
       
        return ['success' => false, 'message' => $conn->error];
    }
}

// FUngsi Tampil Transaction
function getTransaction()
{
    global $conn;
    $sql = "SELECT * FROM transaksi";
    $result = $conn->query($sql);
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    return $data;
}

// Handle Request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Handle Create
    if ($_GET['action'] === 'create') {
        echo json_encode(createData($_POST['nama'], $_POST['harga'], $_POST['stok'], $_POST['kategori'], $_POST['tanggal_masuk']));
    }
    // Handle Update
    else if ($_GET['action'] === 'update') {
        echo json_encode(updateData($_POST['id'], $_POST['nama'], $_POST['harga'], $_POST['stok'], $_POST['kategori'], $_POST['tanggal_masuk']));
    }
    // Handle Delete
    else if ($_GET['action'] === 'delete') {
        echo json_encode(deleteData($_POST['id']));
    }
    // Handle Create Transaction
    else if ($_GET['action'] === 'createTransaction') {
        echo json_encode(createTransaction($_POST['barangId'], $_POST['jumlahBeli']));
    }
} else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle Read Product
    if ($_GET['action'] === 'read') {
        echo json_encode(readData(null, null));
    } else if ($_GET['action'] === 'detailProduct') {
        echo json_encode(readData(($_GET['id']), null));
    } else if ($_GET['action'] === 'search') {
        echo json_encode(readData(null, $_GET['keyword']));
    }
    // Handle Read Transaction
    else if ($_GET['action'] === 'transaction') {
        echo json_encode(readDataTransaction());
    }
}

$conn->close();
