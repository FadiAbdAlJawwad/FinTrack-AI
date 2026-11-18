import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareWidgetAsImage({
    required GlobalKey key,
    String fileName = 'receipt.png',
    required double pixelRatio,
    String? text,
  }) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/$fileName';
    final file = File(imagePath);
    await file.writeAsBytes(pngBytes);

    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(imagePath)], text: text),
      );
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Swallow deletion errors
      }
    }
  }
}
