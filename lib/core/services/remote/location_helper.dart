import 'package:taborq/core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

Future<void> openLocationOnMap(
  double lat,
  double lng,
  BuildContext context,
) async {
  // استخدام الـ Scheme الرسمي لخرائط جوجل والـ URI الموصى به
  final Uri googleMapUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
  );

  try {
    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $googleMapUrl';
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open the map: $e')));
  }
}

Future<void> confirmOpenLocationOnMap(
  BuildContext context,
  double lat,
  double lng,
) async {
  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Open Map'),
        content: const Text('Do you want to open this location in Maps?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Open',
              style: TextStyle(color: AppColors.lightColor),
            ),
          ),
        ],
      );
    },
  );

  if (shouldOpen == true) {
    await openLocationOnMap(lat, lng, context);
  }
}
