import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> capturePhoto(BuildContext context) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    maxWidth: 640,
    maxHeight: 480,
    imageQuality: 85,
  );
  if (image == null) return null;
  return await image.readAsBytes();
}
