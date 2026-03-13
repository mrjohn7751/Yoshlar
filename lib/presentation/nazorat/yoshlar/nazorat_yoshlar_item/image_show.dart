// To'liq ekranda ko'rish sahifasi
import 'package:flutter/material.dart';

class FullImageGallery extends StatelessWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // X yopish tugmasi
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        itemCount: images.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                images[index].url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Chaqirish uchun qulay funksiya
void openImageGallery(BuildContext context, List<dynamic> images, int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          FullImageGallery(images: images, initialIndex: index),
    ),
  );
}
