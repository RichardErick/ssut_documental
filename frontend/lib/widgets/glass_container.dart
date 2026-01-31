import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color color;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius = 24,
    this.color = Colors.white,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color.withOpacity(kIsWeb ? opacity.clamp(0.3, 0.95) : opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ??
          Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );

    final content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}
