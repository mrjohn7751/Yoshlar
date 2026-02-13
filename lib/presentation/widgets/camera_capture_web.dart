import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'web_camera_dialog.dart';

Future<Uint8List?> capturePhoto(BuildContext context) {
  return WebCameraCaptureDialog.show(context);
}
