// https://github.com/chetnasingh00/petpoint_app/blob/868d1d59a55e6017e5b2f572cb184d90b1b0616f/lib/widgets/fancy_card.dart
import 'package:flutter/material.dart';

class FancyCard extends StatelessWidget {
  final Widget child;
  final String? imageUrl;
  final double radius;
  final EdgeInsets padding;

  const FancyCard({
    super.key,
    required this.child,
    this.imageUrl,
    this.radius = 14,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    // card with optional image on the left; ensure consistent height/ratio
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      padding: padding,
      child: Row(
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: AspectRatio(
                  aspectRatio: 1.0, // square thumbnail for consistent layout
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.pets, size: 42, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          if (imageUrl != null) const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}