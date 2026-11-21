import 'package:flutter_foodstore/resource/model/transaction_detail.dart';

class OrderModel {
  final int id;
  final int customerId;
  final String provinceName;
  final String cityName;
  final String districtName;
  final String subdistrictName;
  final int zipCode;
  final String fullAddress;
  final String invoice;
  final int weight;
  final double total;
  final String status;
  final String? snapToken; // Wajib Nullable karena dari DB nilainya null
  final String createdAt;
  final String updatedAt;
  // ✅ Baru: status pengiriman/fulfillment (terpisah dari 'status'
  // pembayaran). Nilai: ordered, processed, on_delivery, delivered.
  final String orderStatus;
  // ✅ Baru: daftar item di transaksi ini (hasil eager load
  // 'transactionDetails.product' di MyOrderController).
  final List<TransactionDetail> transactionDetails;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.provinceName,
    required this.cityName,
    required this.districtName,
    required this.subdistrictName,
    required this.zipCode,
    required this.fullAddress,
    required this.invoice,
    required this.weight,
    required this.total,
    required this.status,
    this.snapToken,
    required this.createdAt,
    required this.updatedAt,
    this.orderStatus = 'ordered',
    this.transactionDetails = const [],
  });

  /// Total jumlah item (qty dijumlah dari semua produk di transaksi ini)
  int get totalItems =>
      transactionDetails.fold(0, (sum, item) => sum + (item.qty ?? 0));

  /// Gambar produk pertama, buat thumbnail di kartu order (null kalau kosong)
  String? get firstProductImage =>
      transactionDetails.isNotEmpty ? transactionDetails.first.product?.image : null;

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? 0,
      customerId: map['customer_id'] ?? 0,
      provinceName: map['province_name'] ?? '',
      cityName: map['city_name'] ?? '',
      districtName: map['district_name'] ?? '',
      subdistrictName: map['subdistrict_name'] ?? '',
      zipCode: map['zip_code'] ?? 0,
      fullAddress: map['full_address'] ?? '',
      invoice: map['invoice'] ?? '',
      weight: map['weight'] ?? 0,
      // Parse aman String "45000.00" ke double
      total: double.tryParse(map['total'].toString()) ?? 0.0,
      status: map['status'] ?? 'pending',
      snapToken: map['snap_token'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      orderStatus: map['order_status'] ?? 'ordered',
      // ✅ Laravel serialize relasi 'transactionDetails' jadi key
      // 'transaction_details' (snake_case) di JSON.
      transactionDetails: map['transaction_details'] == null
          ? []
          : List<TransactionDetail>.from(
              (map['transaction_details'] as List)
                  .map((item) => TransactionDetail.fromMap(item)),
            ),
    );
  }
}