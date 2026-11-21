import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/current_helper.dart';
import 'package:flutter_foodstore/resource/model/cart_response_model.dart';

class CartCard extends StatefulWidget {
  final Cart cart;
  const CartCard({super.key, required this.cart});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  /// **✅ Helper Logika Pemanggilan Gambar Produk**
  String _getImageUrl(String? imageInput) {
    if (imageInput == null || imageInput.isEmpty || imageInput == 'null') {
      return '';
    }

    String imagePath = imageInput.trim();

    // Jika dari API backend sudah berupa URL utuh (http/https)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Bersihkan prefix jika berupa path relatif
    if (imagePath.startsWith('public/')) {
      imagePath = imagePath.replaceFirst('public/', '');
    }
    if (imagePath.startsWith('storage/')) {
      imagePath = imagePath.replaceFirst('storage/', '');
    }
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    final baseUrl = AppConfig.STORAGE_IMAGE.endsWith('/')
        ? AppConfig.STORAGE_IMAGE
        : '${AppConfig.STORAGE_IMAGE}/';

    return '$baseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(widget.cart.product?.image);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cart.product?.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyHelper.formatRupiah(
                            widget.cart.product?.price?.toDouble() ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(widget.cart.id),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.orangeAccent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        onPressed: () => _decreaseQuantity(
                          widget.cart.productId ?? 0,
                          widget.cart.id ?? 0,
                          widget.cart.qty ?? 0,
                        ),
                      ),
                      Text(
                        widget.cart.qty.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () => _increaseQuantity(
                          widget.cart.productId ?? 0,
                          widget.cart.id ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int? id) {
    context.read<CartBloc>().add(CartEvent.removeCart(cartId: id ?? 0));
  }

  void _decreaseQuantity(int productId, int cartId, int qty) {
    if (qty == 1) {
      return;
    }
    context.read<CartBloc>().add(
          CartEvent.decrement(productId: productId, cartId: cartId),
        );
  }

  void _increaseQuantity(int productId, int cartId) {
    context.read<CartBloc>().add(
          CartEvent.increment(productId: productId, cartId: cartId),
        );
  }
}