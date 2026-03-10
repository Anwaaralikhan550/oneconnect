import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_constants.dart';

class StickyFooter extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;

  const StickyFooter({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
  });

  void _handleNavigation(BuildContext context, int index) {
    // Call custom handler if provided
    if (onItemTapped != null) {
      onItemTapped!(index);
      return;
    }

    // Default navigation behavior
    if (selectedIndex == index) return;

    switch (index) {
      case 0: // Home
        Navigator.pushNamedAndRemoveUntil(
            context, '/main-screen-of-oneconnect', (route) => false);
        break;
      case 1: // Search
        Navigator.pushNamed(context, '/search');
        break;
      case 2: // Scan
        _showScanDialog(context);
        break;
      case 3: // Call
        _showCallDialog(context);
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/edit-profile');
        break;
    }
  }

  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Scan QR Code'),
          content: const Text(
              'QR code scanning functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF0092AC)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Contact Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Customer Support',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Phone: ${AppConstants.defaultPhoneNumber}'),
              Text('Email: ${AppConstants.supportEmail}'),
              SizedBox(height: 10),
              Text('Available: ${AppConstants.supportHours}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF0092AC)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterItem(
                context, 'assets/images/footer_home_complete.svg', 'Home', 0),
            _buildFooterItem(context,
                'assets/images/footer_search_complete.svg', 'Search', 1),
            _buildScanButton(context),
            _buildFooterItem(
                context, 'assets/images/footer_call_icon.svg', 'Call', 3),
            _buildFooterItem(
                context, 'assets/images/figma_profile_icon.svg', 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(
      BuildContext context, String iconPath, String label, int index) {
    bool isActive = selectedIndex == index;

    return InkWell(
      onTap: () => _handleNavigation(context, index),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isActive ? const Color(0xFF0092AC) : const Color(0xFF484C52),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color:
                  isActive ? const Color(0xFF0092AC) : const Color(0xFF484C52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(0, -6),
          child: InkWell(
            onTap: () => _handleNavigation(context, 2), // Index 2 for scan
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              width: 56,
              height: 56,
              child: SvgPicture.asset(
                'assets/images/Container.svg',
                width: 56,
                height: 56,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
