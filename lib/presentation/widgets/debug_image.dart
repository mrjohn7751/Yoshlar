import 'package:flutter/material.dart';

/// Rasm yuklash widgeti. Rasm bo'lmasa default avatar ko'rsatadi.
class DebugNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? rawBackendValue;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const DebugNetworkImage({
    super.key,
    required this.imageUrl,
    this.rawBackendValue,
    this.height = 80,
    this.width = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _defaultAvatar();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar();
        },
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Icon(Icons.person, size: height * 0.5, color: Colors.blue),
    );
  }
}
