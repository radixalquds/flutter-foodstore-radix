import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/order/order_cubit.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/convert_date.dart';
import 'package:flutter_foodstore/core/utils/current_helper.dart';
import 'package:flutter_foodstore/core/utils/utils.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart' show AppColors;
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:go_router/go_router.dart';

/// ✅ Status di database ini murni status PEMBAYARAN (dari Midtrans),
/// bukan status pengiriman. Tab filter & badge di bawah disesuaikan
/// dengan status asli yang benar-benar ada: 'pending', 'success', dan
/// status lain (dianggap gagal/batal/expired).
enum _OrderFilter { all, pending, success, failed }

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  _OrderFilter _activeFilter = _OrderFilter.all;

  bool _matchesFilter(OrderModel order) {
    switch (_activeFilter) {
      case _OrderFilter.all:
        return true;
      case _OrderFilter.pending:
        return order.status == 'pending';
      case _OrderFilter.success:
        return order.status == 'success';
      case _OrderFilter.failed:
        return order.status != 'pending' && order.status != 'success';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loadedOrder: (orders, hasMore) {
              final filtered = orders.where(_matchesFilter).toList();
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(orders.length),
                        _buildFilterTabs(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 110),
                            itemCount: filtered.length +
                                (hasMore && _activeFilter == _OrderFilter.all
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index >= filtered.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 8,
                                  ),
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      context
                                          .read<OrderCubit>()
                                          .fetchOrders();
                                    },
                                    child: const Text(
                                      "Load More",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                              return OrderCard(order: filtered[index]);
                            },
                          ),
                  ),
                ],
              );
            },
            orElse: () => const Center(child: Text('Something went wrong')),
          );
        },
      ),
    );
  }

  /// ✅ Header ringkas ala "My Orders" di target desain.
  Widget _buildHeader(int totalCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Track your order status and view your history',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Tab filter status: All / Pending / Success / Failed.
  /// ⚠️ Ini cuma filter di data yang sudah termuat di layar (client-side).
  /// Kalau kamu punya banyak order & butuh filter yang akurat lintas
  /// halaman/pagination, backend index() perlu ditambah query param
  /// status (?status=pending) — kasih tau aku kalau mau dibuatkan.
  Widget _buildFilterTabs() {
    final tabs = [
      (_OrderFilter.all, 'All'),
      (_OrderFilter.pending, 'Pending'),
      (_OrderFilter.success, 'Success'),
      (_OrderFilter.failed, 'Failed'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final (filter, label) = tabs[index];
            final isActive = _activeFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _activeFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  /// Mapping status pembayaran asli (bukan status pengiriman) ke label +
  /// warna badge. `success` = sudah dibayar, `pending` = menunggu bayar,
  /// selain itu (failed/expire/cancel dari Midtrans) = dianggap gagal.
  ({String label, Color color, IconData icon}) _statusInfo() {
    switch (order.status) {
      case 'success':
        return (
          label: 'Paid',
          color: AppColors.secondary,
          icon: Icons.check_circle_rounded,
        );
      case 'pending':
        return (
          label: 'Pending Payment',
          color: Colors.orange.shade700,
          icon: Icons.schedule_rounded,
        );
      default:
        return (
          label: order.status.capitalize(),
          color: Colors.red.shade600,
          icon: Icons.cancel_rounded,
        );
    }
  }

  static const _deliverySteps = [
    ('ordered', 'Ordered', Icons.receipt_long_rounded),
    ('processed', 'Processed', Icons.inventory_2_rounded),
    ('on_delivery', 'On Delivery', Icons.local_shipping_rounded),
    ('delivered', 'Delivered', Icons.home_rounded),
  ];

  int get _currentStepIndex =>
      _deliverySteps.indexWhere((s) => s.$1 == order.orderStatus).clamp(0, 3);

  Color get _deliveryColor {
    switch (order.orderStatus) {
      case 'delivered':
        return AppColors.secondary;
      case 'on_delivery':
        return Colors.blue.shade600;
      case 'processed':
        return AppColors.primary;
      default:
        return Colors.grey.shade500;
    }
  }

  String get _deliveryLabel {
    switch (order.orderStatus) {
      case 'delivered':
        return 'Completed';
      case 'on_delivery':
        return 'On Delivery';
      case 'processed':
        return 'Processing';
      default:
        return 'Order Placed';
    }
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${AppConfig.STORAGE_PATH}$path';
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo();
    final itemCount = order.totalItems;

    return Container(
      margin: const EdgeInsets.only(bottom: 14, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final param = (order.snapToken != null && order.snapToken!.isNotEmpty)
              ? order.snapToken!
              : order.id.toString();

          if (param.isNotEmpty) {
            context.push('/orderDetail/$param');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID Transaksi tidak ditemukan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Thumbnail produk pertama (kalau ada datanya)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: order.firstProductImage != null
                      ? Image.network(
                          _imageUrl(order.firstProductImage),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imageFallback(),
                        )
                      : _imageFallback(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.invoice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chevron_right_rounded,
                              size: 15, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          itemCount > 0
                              ? '$itemCount item${itemCount > 1 ? 's' : ''} · '
                              : '',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          CurrencyHelper.formatRupiah(order.total),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          ConvertDate.convertDate(order.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (order.status == 'success')
                      _buildDeliverySection()
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: status.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, size: 13, color: status.color),
                            const SizedBox(width: 5),
                            Text(
                              status.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: status.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Badge status pengiriman + progress stepper (Ordered → Processed →
  /// On Delivery → Delivered), cuma muncul kalau pembayarannya sudah
  /// 'success'. Datanya dari kolom `order_status` yang diupdate manual
  /// oleh admin lewat Filament.
  Widget _buildDeliverySection() {
    final currentIndex = _currentStepIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _deliveryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping_rounded, size: 13, color: _deliveryColor),
              const SizedBox(width: 5),
              Text(
                _deliveryLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: _deliveryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_deliverySteps.length * 2 - 1, (i) {
            // index genap = titik step, index ganjil = garis penghubung
            if (i.isOdd) {
              final lineDone = (i ~/ 2) < currentIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: lineDone ? _deliveryColor : Colors.grey.shade300,
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final step = _deliverySteps[stepIndex];
            final isDone = stepIndex <= currentIndex;
            final isCurrent = stepIndex == currentIndex;
            return Column(
              children: [
                Container(
                  width: isCurrent ? 22 : 18,
                  height: isCurrent ? 22 : 18,
                  decoration: BoxDecoration(
                    color: isDone ? _deliveryColor : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: _deliveryColor.withOpacity(0.3), width: 3)
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : step.$3,
                    size: isCurrent ? 13 : 10,
                    color: isDone ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          children: _deliverySteps
              .map((step) => Expanded(
                    child: Text(
                      step.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.background,
      child: Icon(Icons.fastfood_rounded, color: AppColors.primary.withOpacity(0.5)),
    );
  }
}