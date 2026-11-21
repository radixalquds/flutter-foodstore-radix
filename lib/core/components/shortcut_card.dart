import 'package:flutter/material.dart';

/// Kartu shortcut besar ala "Our Menu" / "My Orders".
/// ⚠️ Route tujuan tombol masih perlu disesuaikan dengan app_router.dart kamu
/// (lihat parameter onTap saat dipanggil dari home_page.dart).
class ShortcutCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback? onTap;

  const ShortcutCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.backgroundColor,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: -6,
            child: Icon(icon, size: 64, color: accentColor.withOpacity(0.18)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: accentColor),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: accentColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}