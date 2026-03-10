import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'partner_booking_detail_screen.dart';

class PartnerBookingsScreen extends StatefulWidget {
  const PartnerBookingsScreen({super.key});

  @override
  State<PartnerBookingsScreen> createState() => _PartnerBookingsScreenState();
}

class _PartnerBookingsScreenState extends State<PartnerBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();
    });
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final ok = await provider.updateBookingStatus(bookingId: bookingId, status: status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Booking updated' : (provider.error ?? 'Update failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.bookings.isEmpty) {
            return const Center(child: Text('No booking requests'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyBookings(),
            child: ListView.builder(
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                final b = provider.bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.customerName ?? 'Customer',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text('Service: ${b.serviceType}'),
                        Text('Status: ${b.status}'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (b.status.toUpperCase() == 'PENDING') ...[
                              OutlinedButton(
                                onPressed: () => _updateStatus(b.bookingId, 'ACCEPTED'),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _updateStatus(b.bookingId, 'CANCELLED'),
                                child: const Text('Reject'),
                              ),
                              const Spacer(),
                            ],
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PartnerBookingDetailScreen(booking: b),
                                  ),
                                );
                              },
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
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

