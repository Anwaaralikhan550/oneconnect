import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../utils/store_links.dart';
import '../widgets/profile_image.dart';
import '../widgets/sticky_footer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isPushNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          _buildHeader(),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  // Profile Section
                  _buildProfileSection(),
                  
                  const SizedBox(height: 15),
                  // Main Settings Section
                  _buildMainSection(),
                  
                  // Bottom padding to account for shared footer
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StickyFooter(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar with back button, title, and notification
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3195AB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF515151),
                      ),
                    ),
                    // Notification icon
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                      child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCD29),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 16,
                      ),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Profile image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF044870),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: buildProfileImage(
                      auth.user?.profilePhotoUrl,
                      fallbackIcon: Icons.person,
                      iconSize: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.user?.name ?? 'User',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF353535),
                        ),
                      ),
                      Text(
                        auth.user?.email ?? '',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF353535),
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout button
                TextButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6767),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Settings Group 1
          _buildSettingsGroup([
            _buildSettingItem(
              iconAsset: 'assets/images/edit_profile_icon.svg',
              title: 'Edit Profile',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/privacy_icon.svg',
              title: 'Privacy',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/notification_bell_icon.svg',
              title: 'Push Notification',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/push-notification-settings');
              },
            ),
            _buildSettingItem(
              iconData: Icons.favorite,
              iconColor: Color(0xFFFF5050),
              title: 'Your Favorites',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/your-favorites');
              },
            ),
          ]),
          
          const SizedBox(height: 15),
          
          // Rating Section
          _buildRatingSection(),
          
          const SizedBox(height: 15),
          
          // Settings Group 2
          _buildSettingsGroup([
            _buildSettingItem(
              iconAsset: 'assets/images/document_icon.svg',
              title: 'Terms and Conditions',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/terms-and-conditions');
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/info_icon.svg',
              title: 'About the application',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/about-app');
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/help_icon.svg',
              title: 'Frequently asked Questions',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/faq');
              },
            ),
          ]),
          
          const SizedBox(height: 15),
          
          // Individual Actions
          _buildIndividualAction(
            iconAsset: 'assets/images/share_icon.svg',
            title: 'Share the application',
            onTap: () {
              Share.share('Check out OneConnect - your one-stop community app! Download now.');
            },
          ),
          
          const SizedBox(height: 10),
          
          _buildIndividualAction(
            iconAsset: 'assets/images/delete_icon.svg',
            title: 'Request for account deletion',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text('Are you sure you want to request account deletion? This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
                        if (!context.mounted) return;
                        if (ok) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account deletion failed'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 15),
          
          // Settings Group 3
          _buildSettingsGroup([
            _buildSettingItem(
              iconAsset: 'assets/images/data_usage_icon.svg',
              title: 'Data Usage policy',
              hasArrow: true,
              onTap: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/feedback_icon.svg',
              title: 'Review the application',
              hasArrow: true,
              onTap: () async {
                final ok = await StoreLinks.openStoreListing();
                if (!ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Store link is not configured')),
                  );
                }
              },
            ),
            _buildSettingItem(
              iconAsset: 'assets/images/contact_icon.svg',
              title: 'Contact us',
              hasArrow: true,
              onTap: () async {
                final url = Uri.parse('mailto:support@oneconnect.pk');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.15),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingItem({
    String? iconAsset,
    IconData? iconData,
    Color? iconColor,
    required String title,
    bool hasArrow = false,
    bool hasToggle = false,
    bool toggleValue = false,
    VoidCallback? onTap,
    Function(bool)? onToggle,
  }) {
    final rowContent = Row(
      children: [
        // Icon
        if (iconAsset != null)
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
          )
        else if (iconData != null)
          Icon(
            iconData,
            size: 20,
            color: iconColor ?? const Color(0xFF3195AB),
          ),
        
        const SizedBox(width: 15),
        
        // Title
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353535),
            ),
          ),
        ),
        
        // Arrow or Toggle
        if (hasArrow)
          const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Color(0xFF217996),
          ),
        
        if (hasToggle)
          Switch(
            value: toggleValue,
            onChanged: onToggle,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF3195AB);
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (!states.contains(WidgetState.selected)) {
                return const Color(0xFFCDCDCD);
              }
              return null;
            }),
          ),
      ],
    );

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: hasArrow && onTap != null
          ? GestureDetector(
              onTap: onTap,
              child: rowContent,
            )
          : rowContent,
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.15),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 5 stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => 
              const Icon(
                Icons.star,
                size: 20,
                color: Color(0xFFFFCD29),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Rate the application',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353535),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualAction({
    required String iconAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.15),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            // Icon
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
            ),

            const SizedBox(width: 15),

            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF353535),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

