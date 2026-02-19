import 'package:flutter/material.dart';

/// Rasm yuklanmasa URL va xato sababini KO'RSATADIGAN debug widget.
/// rawBackendValue - backend qaytargan xom qiymat (filtrlashdan oldin).
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

    // URL null yoki bo'sh - SABAB KO'RSATILADI
    if (url == null || url.isEmpty) {
      return GestureDetector(
        onTap: () => _showInfoDialog(
          context,
          url,
          'Backend qaytargan xom qiymat: "${rawBackendValue ?? "NULL"}"\n\n'
          'resolveImageUrl natijasi: NULL\n\n'
          'Sabab: ${_nullReason()}',
        ),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 20, color: Colors.orange.shade400),
              const SizedBox(height: 2),
              Text(
                'raw: ${rawBackendValue ?? "null"}',
                style: TextStyle(fontSize: 7, color: Colors.orange.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text('bosing', style: TextStyle(fontSize: 8, color: Colors.orange.shade400)),
            ],
          ),
        ),
      );
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
            onTap: () => _showInfoDialog(
              context,
              url,
              'Xatolik: ${error.toString()}\n\n'
              'Backend xom qiymat: "${rawBackendValue ?? "?"}"',
            ),
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.red.shade400, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      url.length > 30 ? '...${url.substring(url.length - 30)}' : url,
                      style: TextStyle(fontSize: 7, color: Colors.red.shade500),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('bosing', style: TextStyle(fontSize: 8, color: Colors.red.shade400)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _nullReason() {
    final raw = rawBackendValue;
    if (raw == null) return 'Backend photo/image maydonini null qaytardi (bazada photo ustuni bo\'sh)';
    if (raw.isEmpty) return 'Backend bo\'sh string qaytardi';
    if (raw == '0' || raw == '1' || raw == 'true' || raw == 'false') {
      return 'Backend noto\'g\'ri qiymat qaytardi: "$raw" (bu fayl yo\'li emas)';
    }
    if (!raw.contains('/')) {
      return 'Backend "$raw" qaytardi - bu to\'g\'ri fayl yo\'li emas (/ belgisi yo\'q)';
    }
    return 'Noma\'lum sabab';
  }

  void _showInfoDialog(BuildContext context, String? url, String info) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rasm Debug', style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rasm URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  url ?? 'NULL',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Backend xom qiymat:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  rawBackendValue ?? 'NULL (backend bu maydonni qaytarmagan)',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.blue.shade700),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Tafsilot:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  info,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
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
