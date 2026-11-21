import 'package:flutter/material.dart';

/// Baris fitur statis: Fast Delivery, Secure Payment, 24/7 Support, Fresh
/// Ingredients. Murni dekorasi/marketing copy — tidak ada data dinamis.
class FeatureBadgeRow extends StatelessWidget {
  const FeatureBadgeRow({super.key});

  static const _items = [
    (Icons.delivery_dining_rounded, 'Fast Delivery', 'Your food, our priority',
        Color(0xFFFF7A1A)),
    (Icons.verified_user_rounded, 'Secure Payment', 'Safe & easy transactions',
        Color(0xFFE85D04)),
    (Icons.headset_mic_rounded, '24/7 Support', "We're always here",
        Color(0xFFFF9800)),
    (Icons.eco_rounded, 'Fresh Ingredients', 'Quality you can taste',
        Color(0xFF2E7D32)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFDD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(child: _buildItem(item.$1, item.$2, item.$3, item.$4)))
            .toList(),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}