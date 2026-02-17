import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

/// Web da HTTP kontekstda ham ishlaydigan clipboard helper.
/// Avval Clipboard API dan foydalanadi, ishlamasa JS fallback ishlatadi.
Future<bool> copyToClipboard(String text) async {
  if (kIsWeb) {
    return _copyOnWeb(text);
  }
  // Mobile/Desktop
  await Clipboard.setData(ClipboardData(text: text));
  return true;
}

bool _copyOnWeb(String text) {
  try {
    // Fallback: textarea yaratib execCommand('copy') ishlatish
    final textarea = web.document.createElement('textarea') as web.HTMLTextAreaElement;
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    textarea.style.left = '-9999px';
    web.document.body?.appendChild(textarea);
    textarea.select();
    final result = web.document.execCommand('copy');
    textarea.remove();
    return result;
  } catch (_) {
    return false;
  }
}
