import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/order/order_cubit.dart';
import 'package:flutter_foodstore/bloc/review_product/review_product_cubit.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/convert_date.dart';
import 'package:flutter_foodstore/core/utils/current_helper.dart';
import 'package:flutter_foodstore/core/utils/utils.dart';
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:flutter_foodstore/resource/model/transaction_detail.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderModel? order;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewProductCubit, ReviewProductState>(
      listener: _reviewProductListener,
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(state),
            floatingActionButton: _buildFloatingActionButton(),
          );
        },
      ),
    );
  }

  void _reviewProductListener(BuildContext context, ReviewProductState state) {
    state.maybeWhen(
      errorReviewProduct: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
      successReviewProduct: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih telah memberikan ulasan'),
            backgroundColor: Colors.green,
          ),
        );
      },
      orElse: () {},
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
        onPressed: () => context.go('/dashboard/order'),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      ),
      title: const Text(
        'Order Detail',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBody(OrderState state) {
    return state.maybeWhen(
      loading: () => const Center(child: CircularProgressIndicator()),
      detail: (detailOrder) {
        final Map<String, dynamic> data =
            (detailOrder.containsKey('data') && detailOrder['data'] != null)
                ? detailOrder['data']
                : detailOrder;

        order = OrderModel.fromMap(data);

        // Ambil data Shipping (Cek dari object 'shipping' atau langsung dari root 'data')
        final Map<String, dynamic> shippingMap = data['shipping'] is Map<String, dynamic> 
            ? data['shipping'] 
            : data;

        final courier = (shippingMap['courier'] ?? shippingMap['courier_type'] ?? shippingMap['shipping_courier'] ?? '-').toString().toUpperCase();
        final cost = (shippingMap['cost'] ?? shippingMap['shipping_cost'] ?? shippingMap['courier_cost'] ?? 0).toString();
        final service = (shippingMap['service'] ?? shippingMap['shipping_service'] ?? shippingMap['courier_service'] ?? '-').toString();

        // Ambil data Transaction Details / Ordered Items
        final List dynamicDetails = data['transaction_details'] ?? data['details'] ?? data['order_details'] ?? [];
        final List<TransactionDetail> transaction = dynamicDetails
            .map((e) => TransactionDetail.fromMap(e as Map<String, dynamic>))
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderDetailsSection(order),
              const SizedBox(height: 20),
              _buildDeliveryDetailsSection(order),
              const SizedBox(height: 20),
              _buildShippingDetailsSection(courier, cost, service),
              const SizedBox(height: 20),
              _buildOrderedItemsSection(transaction),
            ],
          ),
        );
      },
      error: (message) => Center(child: Text(message)),
      orElse: () => const Center(child: Text('Something went wrong')),
    );
  }

  Widget _buildOrderDetailsSection(OrderModel? order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.shopping_basket_outlined,
              title: 'Order Details',
            ),
            const SizedBox(height: 10),
            _orderDetailItem(
              title: 'Invoice Number',
              value: order?.invoice ?? '',
            ),
            _orderDetailItem(
              title: 'Order Date',
              value: ConvertDate.convertDate(order?.createdAt ?? ''),
            ),
            _orderDetailItem(
              title: 'Status',
              value: order?.status.capitalize() ?? '',
              color: order?.status == 'success'
                  ? Colors.green
                  : order?.status == 'pending'
                      ? Colors.orange
                      : Colors.red,
            ),
            _orderDetailItem(
              title: 'Grand Total',
              value: CurrencyHelper.formatRupiah((order?.total ?? 0).toDouble()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsSection(OrderModel? order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.inventory_2_outlined,
              title: 'Delivery Details',
            ),
            const SizedBox(height: 10),
            Text(
              '${order?.fullAddress}, ${order?.subdistrictName}, ${order?.districtName}, ${order?.cityName}, ${order?.provinceName}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetailsSection(String courier, String cost, String service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.local_shipping_outlined,
              title: 'Shipping Details',
            ),
            const SizedBox(height: 10),
            _orderDetailItem(
              title: 'Courier',
              value: courier,
            ),
            _orderDetailItem(
              title: 'Cost',
              value: CurrencyHelper.formatRupiah(double.tryParse(cost) ?? 0),
            ),
            _orderDetailItem(
              title: 'Service',
              value: service,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedItemsSection(List<TransactionDetail> transaction) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              title: 'Ordered Items',
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 10),
            transaction.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Tidak ada item transaksi"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transaction.length,
                    itemBuilder: (context, index) => _orderedItem(transaction[index]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return order?.status == 'pending'
        ? FloatingActionButton.extended(
            onPressed: () async {
              final result =
                  await context.push('/midtransPayment/${order?.snapToken}');
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.toString()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            label:
                const Text('Payment', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.payment_rounded, color: Colors.white),
          )
        : const SizedBox();
  }

  Widget _orderDetailItem(
      {String title = '', String value = '', Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderedItem(TransactionDetail item) {
    final imageUrl = item.product?.image ?? '';
    final fullImageUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${AppConfig.STORAGE_IMAGE}$imageUrl';

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                fullImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product?.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('Quantity: ${item.qty}'),
                  Text(
                    CurrencyHelper.formatRupiah(
                      ((item.price ?? 0) * (item.qty ?? 0)).toDouble(),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            order?.status == 'success'
                ? IconButton.filledTonal(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => _buildReviewDialog(item),
                    ),
                    icon: const Icon(Icons.rate_review, color: Colors.white),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDialog(TransactionDetail item) {
    return AlertDialog(
      title: const Text('Beri Ulasan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Beri rating untuk produk ini:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              maxRating: 5,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis ulasan Anda...',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ulasan tidak boleh kosong'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              //mengirim data ke server
              context.read<ReviewProductCubit>().reviewProduct(
                    item.id ?? 0,
                    item.product?.id ?? 0,
                    _rating.toInt(),
                    _reviewController.text,
                  );
              context.pop();
            }
          },
          child: const Text('Kirim', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _sectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}