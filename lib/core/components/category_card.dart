
import 'package:flutter/material.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart' show AppColors;
import 'package:flutter_foodstore/resource/model/category_model.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int colorIndex;

  const CategoryCard({
    super.key,
    required this.category,
    this.colorIndex = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  // Palet pastel untuk background kategori
  static const List<Color> _bgColors = [
    Color(0xFFFFE3C2),
    Color(0xFFFFD7D7),
    Color(0xFFD6F5E3),
    Color(0xFFD9E8FF),
    Color(0xFFFFF3C4),
    Color(0xFFE6D9FF),
  ];

  // Helper untuk menangani URL gambar kategori
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Gunakan URL langsung jika API sudah mengirim URL lengkap
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Tambahkan base URL hanya untuk path relatif
    final baseUrl = AppConfig.STORAGE_IMAGE.endsWith('/')
        ? AppConfig.STORAGE_IMAGE
        : '${AppConfig.STORAGE_IMAGE}/';

    return '$baseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgColors[widget.colorIndex % _bgColors.length];

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => context.push(
        '/productByCategory',
        extra: widget.category,
      ),
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: ClipOval(
                child: Image.network(
                  _getImageUrl(widget.category.image),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,

                  // Strategi pemuatan gambar untuk Flutter Web
                  webHtmlElementStrategy:
                      WebHtmlElementStrategy.prefer,

                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.fastfood_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.category.name.toString(),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
