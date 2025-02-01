import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class PermissionService {
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    PermissionStatus status;

    // For Android 13 and above
    if (await Permission.photos.status.isDenied) {
      status = await Permission.photos.request();
    }
    // For Android 12 and below
    else if (await Permission.storage.status.isDenied) {
      status = await Permission.storage.request();
    } else {
      status = PermissionStatus.granted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
              'Gallery permission is required to pick images. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return status.isGranted;
  }
}
