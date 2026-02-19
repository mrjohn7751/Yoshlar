import 'package:flutter/material.dart';

/// Rasm yuklanmasa URL va xato sababini ko'rsatadigan debug widget.
class DebugNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const DebugNetworkImage({
    super.key,
    required this.imageUrl,
    this.height = 80,
    this.width = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    // URL null yoki bo'sh
    if (url == null || url.isEmpty) {
      return _placeholder('Rasm yo\'q');
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
            color: Colors.grey.shade100,
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
          return GestureDetector(
            onTap: () => _showErrorDialog(context, url, error),
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.red.shade300, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Xato',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(String text) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.blue),
    );
  }

  void _showErrorDialog(BuildContext context, String url, Object error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rasm yuklanmadi', style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Xatolik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  error.toString(),
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }
}
