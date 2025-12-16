import 'dart:io';
import 'package:mime/mime.dart' show lookupMimeType;

Future<String?> getMimeType(String filePath) async {
  try {
    final file = File(filePath);
    final fileExists = file.existsSync();
    if (!fileExists) {
      return null;
    }
    List<int>? headerBytes;
    try {
      headerBytes = await file.openRead(0, 12).first;
    } catch (_) {}
    final mimeType = lookupMimeType(filePath, headerBytes: headerBytes);
    return mimeType;
  } catch (e) {
    return null;
  }
}
