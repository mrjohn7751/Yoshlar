import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/auth_service.dart';
import 'package:yoshlar/presentation/widgets/camera_capture.dart';

class FaceResetDialog extends StatefulWidget {
  const FaceResetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RepositoryProvider.value(
        value: context.read<AuthService>(),
        child: const FaceResetDialog(),
      ),
    );
  }

  @override
  State<FaceResetDialog> createState() => _FaceResetDialogState();
}

enum _ResetStep { username, camera, loading, success, error }

class _FaceResetDialogState extends State<FaceResetDialog> {
  final _usernameController = TextEditingController();
  _ResetStep _step = _ResetStep.username;
  String? _errorMessage;
  Map<String, dynamic>? _credentials;
  bool _isSpoofError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = "Foydalanuvchi nomini kiriting";
        _step = _ResetStep.username;
      });
      return;
    }

    // Cross-platform kamera (web yoki mobile)
    final bytes = await capturePhoto(context);
    if (bytes == null || !mounted) return;

    await _submitReset(username, bytes);
  }

  Future<void> _submitReset(String username, Uint8List selfieBytes) async {
    setState(() {
      _step = _ResetStep.loading;
      _errorMessage = null;
      _isSpoofError = false;
    });

    try {
      final authService = context.read<AuthService>();
      final response = await authService.faceReset(
        username: username,
        selfieBytes: selfieBytes,
      );
      if (!mounted) return;

      final creds = response['credentials'] as Map<String, dynamic>;
      setState(() {
        _credentials = creds;
        _step = _ResetStep.success;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = safeErrorMessage(e);
      setState(() {
        _errorMessage = errorMsg;
        _isSpoofError = errorMsg.toLowerCase().contains('soxta') ||
            errorMsg.toLowerCase().contains('spoof');
        _step = _ResetStep.error;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nusxalandi"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case _ResetStep.username:
        return _buildUsernameStep();
      case _ResetStep.camera:
        return const SizedBox.shrink();
      case _ResetStep.loading:
        return _buildLoadingStep();
      case _ResetStep.success:
        return _buildSuccessStep();
      case _ResetStep.error:
        return _buildErrorStep();
    }
  }

  Widget _buildUsernameStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_reset, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text(
              "Parolni tiklash",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Yuz orqali parolni tiklash uchun foydalanuvchi nomingizni kiriting va selfie tasdiqlang.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        // Xavfsizlik haqida ogohlantirish
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.security, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Haqiqiy yuzingiz kameraga aniq ko'rinishi kerak. Rasm yoki video qabul qilinmaydi.",
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: "Foydalanuvchi nomi",
            hintText: "username",
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: _errorMessage,
          ),
          onSubmitted: (_) => _openCamera(),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Bekor qilish"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text("Selfie olish"),
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
    );
  }

  Widget _buildLoadingStep() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          "Yuz tekshirilmoqda...",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          "Tiriklik va o'xshashlik tekshirilmoqda",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final username = _credentials?['username'] ?? '';
    final password = _credentials?['password'] ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 12),
        const Text(
          "Parol muvaffaqiyatli tiklandi!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildCredentialRow("Login", username),
        const SizedBox(height: 12),
        _buildCredentialRow("Parol", password),
        const SizedBox(height: 8),
        const Text(
          "Ushbu ma'lumotlarni xavfsiz joyga saqlang!",
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Yopish"),
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(value),
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: "Nusxalash",
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isSpoofError ? Icons.gpp_bad : Icons.error_outline,
          color: _isSpoofError ? Colors.orange : Colors.red,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          _isSpoofError ? "Soxta rasm aniqlandi!" : "Xatolik",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? "Noma'lum xatolik",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _isSpoofError ? Colors.orange.shade800 : Colors.red,
            fontSize: 14,
          ),
        ),
        if (_isSpoofError) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Haqiqiy yuzingizni kameraga to'g'ridan-to'g'ri ko'rsating. "
                    "Telefon ekranidagi yoki qog'ozdagi rasm ishlamaydi.",
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Yopish"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _step = _ResetStep.username;
                    _errorMessage = null;
                    _isSpoofError = false;
                  });
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("Qayta urinish"),
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
    );
  }
}
