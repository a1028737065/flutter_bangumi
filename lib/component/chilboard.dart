import 'package:flutter/services.dart';

class ClipboardData {
  /// Creates data for the system clipboard.
  const ClipboardData({this.text});

  /// Plain text variant of this clipboard data.
  final String text;
}

class Clipboard {
  Clipboard._();

  static const String kTextPlain = 'text/plain';

  // 将ClipboardData中的内容复制到粘贴板。
  static Future<void> setData(ClipboardData data) async {
    await SystemChannels.platform.invokeMethod<void>(
      'Clipboard.setData',
      <String, dynamic>{
        'text': data.text,
      },
    );
  }
}