import 'package:flutter/material.dart';

class RelocLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const RelocLogo({
    super.key,
    this.size = 120,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/Appicons/logo.png', // path in your assets folder
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
