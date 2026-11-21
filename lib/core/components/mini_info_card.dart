import 'package:flutter/material.dart';

/// Kartu kecil ala "Member Rewards" / kartu kutipan "Good Food Brings
/// People Together". Statis, murni dekorasi.
class MiniInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;
  final String? buttonLabel;
  final VoidCallback? onTap;

  const MiniInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.accentColor,
    this.buttonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9.5, color: Colors.black54),
            maxLines: 2,
          ),
          if (buttonLabel != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Baris 4 ikon "Quick Access" (Promo, Favorites, History, Help) — statis.
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  static const _items = [
    (Icons.local_offer_rounded, 'Promo'),
    (Icons.favorite_rounded, 'Favorites'),
    (Icons.history_rounded, 'History'),
    (Icons.headset_mic_rounded, 'Help'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFF1976D2), size: 18),
              SizedBox(width: 4),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _items
                .map((item) => CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white,
                      child: Icon(item.$1,
                          size: 13, color: const Color(0xFF1976D2)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}