// IO / fallback implementation: copy CSV to clipboard and no-op print
import 'package:flutter/services.dart';

Future<void> downloadCsv(String filename, String content) async {
  // Fallback: copy CSV content to clipboard for platforms where file download isn't available
  await Clipboard.setData(ClipboardData(text: content));
}

Future<void> printPage() async {
  // No generic print on non-web without extra packages; no-op
  return;
}
