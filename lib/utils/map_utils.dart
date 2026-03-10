import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _launchFirstAvailable(List<Uri> uris, LaunchMode mode) async {
  for (final uri in uris) {
    if (await launchUrl(uri, mode: mode)) {
      return true;
    }
  }
  return false;
}

Future<void> openMapAtCoordinates(
  BuildContext context, {
  required double latitude,
  required double longitude,
  String? label,
}) async {
  final lat = latitude.toStringAsFixed(6);
  final lng = longitude.toStringAsFixed(6);
  final queryLabel = (label ?? '').trim();

  final appUris = <Uri>[
    if (Platform.isAndroid)
      Uri.parse('google.navigation:q=$lat,$lng')
    else if (Platform.isIOS)
      Uri.parse('maps://?ll=$lat,$lng${queryLabel.isNotEmpty ? '&q=${Uri.encodeComponent(queryLabel)}' : ''}'),
  ];

  final webFallbacks = <Uri>[
    if (Platform.isIOS)
      Uri.parse('https://maps.apple.com/?ll=$lat,$lng${queryLabel.isNotEmpty ? '&q=${Uri.encodeComponent(queryLabel)}' : ''}'),
    Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$lat,$lng')}',
    ),
  ];

  final launched =
      await _launchFirstAvailable(appUris, LaunchMode.externalNonBrowserApplication) ||
      await _launchFirstAvailable(appUris, LaunchMode.externalApplication) ||
      await _launchFirstAvailable(webFallbacks, LaunchMode.externalApplication) ||
      await _launchFirstAvailable(webFallbacks, LaunchMode.inAppBrowserView);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open map on this device')),
    );
  }
}

Future<void> openMapForQuery(BuildContext context, String query) async {
  final cleaned = query.trim();
  if (cleaned.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location not available')),
    );
    return;
  }

  final appUris = <Uri>[
    if (Platform.isAndroid) Uri.parse('geo:0,0?q=${Uri.encodeComponent(cleaned)}'),
    if (Platform.isIOS) Uri.parse('maps://?q=${Uri.encodeComponent(cleaned)}'),
  ];

  final webFallbacks = <Uri>[
    if (Platform.isIOS) Uri.parse('https://maps.apple.com/?q=${Uri.encodeComponent(cleaned)}'),
    Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleaned)}',
    ),
  ];

  final launched =
      await _launchFirstAvailable(appUris, LaunchMode.externalNonBrowserApplication) ||
      await _launchFirstAvailable(appUris, LaunchMode.externalApplication) ||
      await _launchFirstAvailable(webFallbacks, LaunchMode.externalApplication) ||
      await _launchFirstAvailable(webFallbacks, LaunchMode.inAppBrowserView);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open map on this device')),
    );
  }
}
