import 'dart:async';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class WebCameraCaptureDialog extends StatefulWidget {
  const WebCameraCaptureDialog({super.key});

  static Future<Uint8List?> show(BuildContext context) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WebCameraCaptureDialog(),
    );
  }

  @override
  State<WebCameraCaptureDialog> createState() => _WebCameraCaptureDialogState();
}

class _WebCameraCaptureDialogState extends State<WebCameraCaptureDialog> {
  late final String _viewId;
  web.HTMLVideoElement? _video;
  web.MediaStream? _stream;
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-${DateTime.now().millisecondsSinceEpoch}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final video = web.HTMLVideoElement()
        ..autoplay = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '12px'
        ..style.transform = 'scaleX(-1)';

      // Platform view ro'yxatdan o'tkazish
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => video,
      );

      // Kamera oqimini olish
      final videoConstraints = <String, dynamic>{
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
      }.jsify()!;

      final constraints = web.MediaStreamConstraints(
        video: videoConstraints,
        audio: false.toJS,
      );

      final stream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      video.srcObject = stream;

      _video = video;
      _stream = stream;

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Kamera ochilmadi. Ruxsat berilganligini tekshiring.");
      }
    }
  }

  Future<Uint8List?> _capture() async {
    final video = _video;
    if (video == null) return null;

    final canvas = web.HTMLCanvasElement()
      ..width = video.videoWidth
      ..height = video.videoHeight;

    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    // Ko'zgu effektini saqlash
    ctx.translate(canvas.width.toDouble(), 0);
    ctx.scale(-1, 1);
    ctx.drawImage(video, 0, 0);

    final dataUrl = canvas.toDataURL('image/jpeg', 0.85.toJS);
    final base64 = dataUrl.split(',').last;

    final bytes = _base64ToBytes(base64);
    return bytes;
  }

  Uint8List _base64ToBytes(String base64) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final lookup = List<int>.filled(256, -1);
    for (int i = 0; i < chars.length; i++) {
      lookup[chars.codeUnitAt(i)] = i;
    }

    final out = <int>[];
    int buffer = 0;
    int bitsCollected = 0;

    for (int i = 0; i < base64.length; i++) {
      final c = base64.codeUnitAt(i);
      if (c == 61) break; // '='
      final val = lookup[c];
      if (val == -1) continue;
      buffer = (buffer << 6) | val;
      bitsCollected += 6;
      if (bitsCollected >= 8) {
        bitsCollected -= 8;
        out.add((buffer >> bitsCollected) & 0xFF);
      }
    }
    return Uint8List.fromList(out);
  }

  void _stopCamera() {
    _stream?.getTracks().toDart.forEach((track) => track.stop());
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  "Selfie tasdiqlash",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Yuzingizni doira ichiga joylashtiring. Yaxshi yorug'lik va aniq ko'rinish ta'minlang.",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 360,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : !_isReady
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                "Kamera yuklanmoqda...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: HtmlElementView(viewType: _viewId),
                            ),
                            // Yuz ramkasi (face overlay)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _FaceOverlayPainter(),
                              ),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _stopCamera();
                      Navigator.pop(context, null);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Bekor qilish",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isReady
                        ? () async {
                            final bytes = await _capture();
                            _stopCamera();
                            if (context.mounted) {
                              Navigator.pop(context, bytes);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.camera, size: 20),
                    label: const Text("Rasmga olish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Yuz joylashishi uchun oval ramka chizuvchi
class _FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);
    final ovalWidth = size.width * 0.45;
    final ovalHeight = size.height * 0.6;

    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Tashqi qismni qoraytirish
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, ovalPath);

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    // Oval chegarasi
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
