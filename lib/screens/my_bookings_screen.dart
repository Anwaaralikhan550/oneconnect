import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();
    });
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Waiting for provider response';
      case 'ACCEPTED':
        return 'Provider accepted your booking';
      case 'STARTED':
        return 'Provider is on the way';
      case 'COMPLETED':
        return 'Service completed';
      case 'CANCELLED':
        return 'Booking cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.bookings.isEmpty) {
            return const Center(child: Text('No bookings yet'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyBookings(),
            child: ListView.separated(
              itemCount: provider.bookings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final b = provider.bookings[index];
                return ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(b.providerName ?? 'Service Provider'),
                  subtitle: Text(_statusLabel(b.status)),
                  trailing: Text(
                    b.status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

