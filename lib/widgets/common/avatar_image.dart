import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double radius;

  const AvatarImage({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.black),
            )
          : null,
    );
  }
}
