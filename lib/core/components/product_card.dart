
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/current_helper.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart' show AppColors;
import 'package:flutter_foodstore/resource/model/product_model.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isPopular;

  const ProductCard({
    super.key,
    required this.product,
    required this.isPopular,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  // Helper URL gambar produk
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Jika API sudah mengirim URL lengkap, gunakan langsung
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Jika masih berupa path relatif
    final baseUrl = AppConfig.STORAGE_PATH.endsWith('/')
        ? AppConfig.STORAGE_PATH
        : '${AppConfig.STORAGE_PATH}/';

    return '$baseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: widget.isPopular ? 12.0 : 0,
        left: widget.isPopular ? 4.0 : 0,
      ),
      child: SizedBox(
        width: widget.isPopular ? 165 : null,
        child: _buildCard(widget.product),
      ),
    );
  }

  Widget _buildCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _navigateToDetailProduct(product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.35,
                      child: Image.network(
                        _getImageUrl(product.image),
                        fit: BoxFit.cover,
                        width: double.infinity,

                        // Strategi pemuatan gambar Flutter Web
                        webHtmlElementStrategy:
                            WebHtmlElementStrategy.prefer,

                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (widget.isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      CurrencyHelper.formatRupiah(
                        product.price?.toDouble() ?? 0,
                      ),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.ratingsAvgRating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        _addToCartButton(product),
                      ],
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

  // Tombol Add to Cart
  Widget _addToCartButton(ProductModel product) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.read<CartBloc>().add(
          CartEvent.addCart(
            productId: product.id ?? 0,
            qty: 1,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_shopping_cart_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // Navigasi ke detail produk
  void _navigateToDetailProduct(ProductModel product) {
    context.push('/detailProduct/${product.slug}');
  }
}
  