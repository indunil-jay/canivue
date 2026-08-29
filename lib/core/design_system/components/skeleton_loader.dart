import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// A single pulsing placeholder block for loading states. Compose several
/// into a shape that mirrors the real content's layout (see
/// [SkeletonLine] for text rows) so the loading state doesn't jump around
/// once real data arrives.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.borderRadius});

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkElevatedSurface : const Color(0xFFEDF2F1);
    final highlight = isDark ? AppColors.darkBorder : const Color(0xFFF7FAF9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value),
            borderRadius: widget.borderRadius ?? AppRadius.smRadius,
          ),
        );
      },
    );
  }
}

/// A text-shaped skeleton line — shorthand for the common case.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.width, this.height = 14});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => SkeletonBox(width: width, height: height, borderRadius: AppRadius.xsRadius);
}
