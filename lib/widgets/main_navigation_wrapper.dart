import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import 'sticky_footer.dart';

class MainNavigationWrapper extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final bool showFooter;

  const MainNavigationWrapper({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.showFooter = true,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 0: // Home
        Navigator.pushNamedAndRemoveUntil(context, '/main-screen-of-oneconnect', (route) => false);
        break;
      case 1: // Search
        Navigator.pushNamed(context, '/search');
        break;
      case 2: // Scan
        _showScanDialog();
        break;
      case 3: // Call
        _showCallDialog();
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/edit-profile');
        break;
    }
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan QR Code'),
          content: const Text('QR code scanning functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Support'),
              const SizedBox(height: 10),
              Text('Phone: ${AppConstants.defaultPhoneNumber}'),
              Text('Email: ${AppConstants.supportEmail}'),
              const SizedBox(height: 10),
              Text('Available: ${AppConstants.supportHours}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          widget.child,

          // Sticky Footer
          if (widget.showFooter)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StickyFooter(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
        ],
      ),
    );
  }
}
