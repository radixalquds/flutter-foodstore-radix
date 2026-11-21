import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/category/category_cubit.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/bloc/product_populer/product_populer_cubit.dart';
import 'package:flutter_foodstore/bloc/slider/slider_cubit.dart';
import 'package:flutter_foodstore/core/components/category_card.dart';
import 'package:flutter_foodstore/core/components/feature_badge_row.dart';
import 'package:flutter_foodstore/core/components/mini_info_card.dart';
import 'package:flutter_foodstore/core/components/product_card.dart';
import 'package:flutter_foodstore/core/components/promo_banner.dart';
import 'package:flutter_foodstore/core/components/shortcut_card.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/resource/model/slider_model.dart';
import 'package:go_router/go_router.dart';

/// 🎨 Palet warna utama tema Food Store (biar konsisten dipakai ulang)
class AppColors {
  static const primary = Color(0xFFFF7A1A); // oranye utama
  static const primaryDark = Color(0xFFE85D04);
  static const secondary = Color(0xFF2E7D32); // hijau harga
  static const background = Color(0xFFFFF8F0); // krem lembut
  static const cardShadow = Color(0x1A000000);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        state.whenOrNull(
          cartStored: (message) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          error: (message) {
            if (message == '401') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  showCloseIcon: true,
                  content: const Text('Please Login First'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
        );
      },
      child: Container(
        width: double.infinity,
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildSliderSection(),
              const SizedBox(height: 20),
              _buildCategorySection(),
              const SizedBox(height: 20),
              _buildPromoBannerRow(),
              const SizedBox(height: 20),
              _buildProductSection(
                title: "Product Popular",
                subtitle: "Most ordered, most loved!",
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.primary,
                cubit: BlocBuilder<ProductPopulerCubit, ProductPopulerState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => _buildLoadingIndicator(),
                      loadedProductPopuler: (products) => products.isNotEmpty
                          ? SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final product = products[index];
                                  return ProductCard(
                                    product: product,
                                    isPopular: true,
                                  );
                                },
                              ),
                            )
                          : _buildEmptyMessage(),
                      orElse: () => _buildErrorMessage("Failed to load popular products"),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const FeatureBadgeRow(),
              ),
              const SizedBox(height: 20),
              _buildShortcutRow(),
              const SizedBox(height: 16),
              _buildMiniInfoRow(),
              const SizedBox(height: 20),
              _buildProductSection(
                title: "Product Terbaru",
                icon: Icons.new_releases_rounded,
                iconColor: AppColors.secondary,
                cubit: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => _buildLoadingIndicator(),
                      loadedProduct: (products, hasMore) => products.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 190,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.66,
                              ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  isPopular: false,
                                );
                              },
                            )
                          : _buildEmptyMessage(),
                      orElse: () => _buildErrorMessage("Failed to load latest products"),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// **✅ 2 Banner Promo statis ala "Pizza Time!" / "Special Food Deal"**
  /// ⚠️ Konten & warna masih hardcode karena belum ada endpoint promo.
  Widget _buildPromoBannerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PromoBanner(
                title: 'Pizza Time!',
                subtitle: 'Get 20% off for all pizza menu',
                buttonLabel: 'Grab Now',
                backgroundColor: const Color(0xFF2E5E3E),
                icon: Icons.local_pizza_rounded,
                onTap: () => _navigateToAllProducts(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PromoBanner(
                title: 'Special Food Deal',
                subtitle: 'Save more, eat happier!',
                buttonLabel: 'Shop Now',
                backgroundColor: const Color(0xFFFCE7C8),
                textColor: Colors.brown.shade800,
                icon: Icons.fastfood_rounded,
                onTap: () => _navigateToAllProducts(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **✅ 2 Kartu Shortcut "Our Menu" & "My Orders"**
  Widget _buildShortcutRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShortcutCard(
              title: 'Our Menu',
              description:
                  'Discover a variety of delicious foods and drinks.',
              buttonLabel: 'View All Menu',
              icon: Icons.restaurant_menu_rounded,
              backgroundColor: const Color(0xFFE7F3DE),
              accentColor: AppColors.secondary,
              onTap: () => _navigateToAllProducts(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ShortcutCard(
              title: 'My Orders',
              description: 'Track your order status and view history.',
              buttonLabel: 'View Orders',
              icon: Icons.shopping_bag_rounded,
              backgroundColor: const Color(0xFFFCE4E4),
              accentColor: Colors.red.shade400,
              onTap: () => context.go('/dashboard/order'),
            ),
          ),
        ],
      ),
    );
  }

  /// **✅ 3 Kartu kecil: Member Rewards, Quick Access, kutipan**
  Widget _buildMiniInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MiniInfoCard(
              title: 'Member Rewards',
              subtitle: 'Collect points & get special offers!',
              icon: Icons.emoji_events_rounded,
              backgroundColor: const Color(0xFFEDE1FF),
              accentColor: const Color(0xFF7B2FE0),
              buttonLabel: 'Join Now',
              onTap: () {
                // TODO: arahkan ke halaman membership kalau sudah ada
              },
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: QuickAccessCard()),
          const SizedBox(width: 10),
          Expanded(
            child: MiniInfoCard(
              title: 'Good Food Brings\nPeople Together',
              subtitle: '',
              icon: Icons.favorite_rounded,
              backgroundColor: const Color(0xFFFFF3D6),
              accentColor: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  /// **✅ Bagian Produk (Popular & Terbaru)**
  Widget _buildProductSection({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget cubit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildSectionHeader(title, subtitle, icon, iconColor),
          ),
          cubit,
        ],
      ),
    );
  }

  /// **✅ Header Setiap Section**
  Widget _buildSectionHeader(
      String title, String? subtitle, IconData icon, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _navigateToAllProducts(),
          child: Row(
            children: [
              Text(
                'Lihat Lainnya',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.primaryDark),
            ],
          ),
        ),
      ],
    );
  }

  /// **✅ Bagian Kategori — dibungkus kartu putih "Find Your Favorite Food"**
  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Your Favorite Food',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Explore our categories',
                            style: TextStyle(
                                fontSize: 10.5, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _navigateToAllProducts(),
                    child: Row(
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => _buildLoadingIndicator(),
                  loaded: (categories) => categories.isNotEmpty
                      ? SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return CategoryCard(
                                category: category,
                                colorIndex: index,
                              );
                            },
                          ),
                        )
                      : _buildEmptyMessage(),
                  orElse: () => _buildErrorMessage("Failed to load categories"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// **✅ Bagian Slider**
  Widget _buildSliderSection() {
    return BlocBuilder<SliderCubit, SliderState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => _buildLoadingIndicator(),
          loaded: (sliders) => _buildImageSlider(sliders),
          orElse: () => _buildErrorMessage("Failed to load sliders"),
        );
      },
    );
  }

  /// **✅ Widget untuk Image Slider**
  Widget _buildImageSlider(List<SliderModel> sliders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sliders.length,
                  onPageChanged: (index) =>
                      setState(() => _currentSlide = index),
                  itemBuilder: (context, index) {
                    final slider = sliders[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          '${AppConfig.STORAGE_IMAGE}${slider.image}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppColors.primary.withOpacity(0.15),
                            child: const Icon(Icons.image_not_supported,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildSliderNavigationButton(Icons.arrow_back_ios_new_rounded, () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }),
              _buildSliderNavigationButton(
                Icons.arrow_forward_ios_rounded,
                () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                alignRight: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sliders.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sliders.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentSlide == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentSlide == index
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// **✅ Tombol Navigasi Slider**
  Widget _buildSliderNavigationButton(
    IconData icon,
    VoidCallback onPressed, {
    bool alignRight = false,
  }) {
    return Positioned(
      left: alignRight ? null : 6,
      right: alignRight ? 6 : null,
      top: 90,
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: IconButton(
          iconSize: 16,
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// **Widget untuk pesan error**
  Widget _buildErrorMessage(String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );

  /// **Widget untuk loading**
  Widget _buildLoadingIndicator() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

  /// **Widget untuk pesan kosong**
  Widget _buildEmptyMessage() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "Tidak ada data tersedia",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );

  /// **Navigasi ke halaman semua produk**
  void _navigateToAllProducts() {
    context.push('/allProducts');
  }
}