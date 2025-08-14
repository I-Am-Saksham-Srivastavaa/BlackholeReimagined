import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

// ignore: avoid_classes_with_only_static_members
class Picker {
  static Future<String> selectFolder({
    required BuildContext context,
    String? message,
  }) async {
    final String? temp = await getDirectoryPath(
      confirmButtonText: message ?? 'Select',
    );
    Logger.root.info('Selected folder: $temp');
    return (temp == null || temp == '/') ? '' : temp;
  }

  static Future<String> selectFile({
    required BuildContext context,
    String? message,
  }) async {
    final XFile? file = await openFile(
      confirmButtonText: message ?? 'Select',
    );

    if (file != null) {
      return file.path == '/' ? '' : file.path;
    }
    return '';
  }
}
