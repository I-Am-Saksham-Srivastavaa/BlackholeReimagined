import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: avoid_classes_with_only_static_members
class ExtStorageProvider {
  // asking for permission
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // requesting all necessary permissions
  static Future<bool> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.audio,
      Permission.photos,
      Permission.videos,
      Permission.microphone,
    ];

    for (final permission in permissions) {
      if (!await requestPermission(permission)) {
        return false;
      }
    }
    return true;
  }

  // getting external storage path
  static Future<String?> getExtStorage({
    required String dirName,
    required bool writeAccess,
  }) async {
    Directory? directory;

    try {
      // checking platform
      if (Platform.isAndroid) {
        if (await requestAllPermissions()) {
          directory = await getExternalStorageDirectory();

          // getting main path
          final String newPath = directory!.path
              .replaceFirst('Android/data/com.infinity.oryn/files', dirName);

          directory = Directory(newPath);

          // checking if directory exist or not
          if (!await directory.exists()) {
            // if directory not exists then creating folder
            await directory.create(recursive: true);
          }
          if (await directory.exists()) {
            try {
              if (writeAccess) {
                await requestPermission(Permission.manageExternalStorage);
              }
              // if directory exists then returning the complete path
              return newPath;
            } catch (e) {
              rethrow;
            }
          }
        } else {
          throw Exception('Permission denied');
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        directory = await getApplicationDocumentsDirectory();
        final finalDirName = dirName.replaceAll('BlackHole/', '');
        return '${directory.path}/$finalDirName';
      } else {
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
        return '${directory.path}/$dirName';
      }
    } catch (e) {
      rethrow;
    }
    return directory.path;
  }
}
