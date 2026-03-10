import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_model.dart';

class PartnerBookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const PartnerBookingDetailScreen({super.key, required this.booking});

  Future<void> _navigateToCustomer(BuildContext context) async {
    final lat = booking.userLatitude;
    final lng = booking.userLongitude;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer location not available')),
      );
      return;
    }

    final uri = Uri.parse('google.navigation:q=$lat,$lng');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open navigation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking.customerName ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Phone: ${booking.customerPhone ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Status: ${booking.status}'),
            const SizedBox(height: 8),
            Text('Service: ${booking.serviceType}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCustomer(context),
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Navigate to Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

