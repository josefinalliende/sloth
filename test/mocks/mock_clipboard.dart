import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart' show TestDefaultBinaryMessengerBinding;

String? Function() mockClipboard() {
  String? content;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        content = (call.arguments as Map)['text'] as String?;
      }
      return null;
    },
  );
  return () => content;
}
