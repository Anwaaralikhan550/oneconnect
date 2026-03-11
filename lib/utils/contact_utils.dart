import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callPhoneNumber(BuildContext context, String rawNumber) async {
  final normalized = rawNumber.trim().replaceAll(RegExp(r'[^0-9+]'), '');
  if (normalized.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number not available')),
    );
    return;
  }

  final phoneUri = Uri(scheme: 'tel', path: normalized);
  final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalNonBrowserApplication,
      ) ||
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open phone dialer')),
    );
  }
}

Future<void> openWhatsAppForNumber(BuildContext context, String rawNumber) async {
  final cleaned = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp number not available')),
    );
    return;
  }

  final whatsappUrl = Uri.parse('https://wa.me/$cleaned');
  final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalNonBrowserApplication,
      ) ||
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      ) ||
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.inAppBrowserView,
      );

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open WhatsApp')),
    );
  }
}
