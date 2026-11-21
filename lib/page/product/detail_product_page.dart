import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/current_helper.dart';
import 'package:flutter_foodstore/resource/model/rating_model.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';

class DetailProductPage extends StatelessWidget {
  const DetailProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildProductDetail(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

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

    // Bersihkan prefix jika ada
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

  /// **✅ Detail Produk**
  Widget _buildProductDetail(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          loadedDetailProduct: (product) {
            return ListView(
              children: [
                _buildImageBanner(product.image, context),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildProductInfo(product),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDescription(product.description),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildReviewSection(product.ratings),
                ),
              ],
            );
          },
          orElse: () => const Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  /// **✅ Gambar Produk (Banner)**
  Widget _buildImageBanner(String? imageUrl, BuildContext context) {
    final finalImageUrl = _getImageUrl(imageUrl);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Image.network(
            finalImageUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 8,
          child: IconButton.filled(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
        ),
      ],
    );
  }

  /// **✅ Informasi Produk**
  Widget _buildProductInfo(product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title ?? "",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CurrencyHelper.formatRupiah(product.price?.toDouble() ?? 0),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green.shade700,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  '${product.ratingsAvgRating} (${product.ratings?.length} Reviews)',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// **✅ Deskripsi Produk**
  Widget _buildDescription(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        HtmlWidget(description ?? ""),
      ],
    );
  }

  /// **✅ Bagian Review & Rating**
  Widget _buildReviewSection(List<RatingModel>? ratings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ratings & Reviews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ratings == null || ratings.isEmpty
            ? _buildNoReviewMessage()
            : _buildReviewList(ratings),
      ],
    );
  }

  /// **✅ Pesan Jika Tidak Ada Review**
  Widget _buildNoReviewMessage() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Text("No reviews available")),
    );
  }

  /// **✅ Daftar Review**
  Widget _buildReviewList(List<RatingModel> ratings) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final review = ratings[index];
        return _buildReviewItem(review);
      },
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(color: Colors.black, thickness: 1),
      ),
    );
  }

  /// **✅ Item Review**
  Widget _buildReviewItem(RatingModel review) {
    final avatarUrl = _getImageUrl(review.customer?.image);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.customer?.name ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildStarRating(review.rating ?? 0),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.review ?? ""),
        ],
      ),
    );
  }

  /// **✅ Star Rating**
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  /// **✅ Tombol Floating Add to Cart**
  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return state.maybeWhen(
          loadedDetailProduct: (product) => FloatingActionButton.extended(
            onPressed: () {
              context
                  .read<CartBloc>()
                  .add(CartEvent.addCart(productId: product.id ?? 0, qty: 1));
            },
            label: const Text(
              'Add to Cart',
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          ),
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}