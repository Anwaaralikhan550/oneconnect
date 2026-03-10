import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../widgets/profile_image.dart';
import '../widgets/sticky_footer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  bool _pushNotificationsEnabled = false;
  bool _isUpdatingPushToggle = false;

  // Responsive helpers
  double _sw(BuildContext context) => MediaQuery.of(context).size.width;
  double _rs(BuildContext context, double design) => (_sw(context) / 390.0) * design;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
      _loadPushNotificationPreference();
    });
  }

  Future<void> _loadPushNotificationPreference() async {
    try {
      final prefs = await _userService.getNotificationPreferences();
      if (!mounted) return;
      setState(() {
        _pushNotificationsEnabled = prefs['notifyPushUpdates'] ?? false;
      });
    } catch (_) {
      // Keep existing UI state if preferences fail to load.
    }
  }

  Future<void> _updatePushNotificationPreference(bool value) async {
    if (_isUpdatingPushToggle) return;
    final oldValue = _pushNotificationsEnabled;
    setState(() {
      _isUpdatingPushToggle = true;
      _pushNotificationsEnabled = value;
    });

    try {
      await _userService.updateNotificationPreferences({'notifyPushUpdates': value});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pushNotificationsEnabled = oldValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save push notification setting')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPushToggle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
                child: Column(
                  children: [
                    _buildUserCard(context),
                    SizedBox(height: _rs(context, 12)),
                    _buildPrimaryActions(context),
                    SizedBox(height: _rs(context, 12)),
                    _buildRatingRow(context),
                    SizedBox(height: _rs(context, 12)),
                    _buildSecondaryActions(context),
                    SizedBox(height: _rs(context, 12)),
                    _buildShareButton(context),
                    SizedBox(height: _rs(context, 12)),
                    _buildSupportActions(context),
                    SizedBox(height: _rs(context, 24)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StickyFooter(selectedIndex: 4),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _rs(context, 118),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _rs(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: Container(
                  width: _rs(context, 35),
                  height: _rs(context, 35),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3195AB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: _rs(context, 18),
                  ),
                ),
              ),
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: _rs(context, 22),
                  color: const Color(0xFF515151),
                ),
              ),
              // Bell icon
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/notification');
                },
                child: SvgPicture.asset(
                  'assets/icons/noti.svg',
                  width: _rs(context, 40),
                  height: _rs(context, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(_rs(context, 12)),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(_rs(context, 12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: _rs(context, 52),
                height: _rs(context, 52),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF044870), width: 2),
                ),
                child: ClipOval(
                  child: buildProfileImage(
                    auth.user?.profilePhotoUrl,
                    fallbackIcon: Icons.person,
                    iconSize: _rs(context, 28),
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 12)),
              // Name + email
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.name ?? 'User',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: _rs(context, 14),
                              color: const Color(0xFF19213D),
                            ),
                          ),
                          SizedBox(height: _rs(context, 4)),
                          Text(
                            auth.user?.email ?? '',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: _rs(context, 12),
                              color: const Color(0xFF6D758F),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Logout
                      GestureDetector(
                        onTap: () async {
                          await Provider.of<AuthProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          }
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: _rs(context, 12),
                            color: const Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _rs(context, 12),
        vertical: _rs(context, 12),
      ),
      decoration: BoxDecoration(
        color: Color(0xffF9F9F9),
        //borderRadius: BorderRadius.circular(_rs(context, 10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_rs(context, 10)),
        child: Row(
          children: [
            Icon(
              icon,
              size: _rs(context, 24),
              color: const Color(0xFF156385),
            ),
            SizedBox(width: _rs(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: _rs(context, 14),
                      color: const Color(0xFF272727),
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: _rs(context, 2)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: _rs(context, 12),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.keyboard_arrow_right,
                  size: _rs(context, 24),
                  color: const Color(0xFF3195AB),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      children: [
        _buildTile(
          context: context,
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () => Navigator.pushNamed(context, '/edit-profile'),
        ),
        _buildTile(
          context: context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy',
          onTap: () => Navigator.pushNamed(context, '/privacy'),
        ),
        _buildTile(
          context: context,
          icon: Icons.notifications_active_outlined,
          title: 'Push Notification',
          trailing: Switch(
            value: _pushNotificationsEnabled,
            onChanged: _isUpdatingPushToggle ? null : _updatePushNotificationPreference,
            activeColor: const Color(0xFF0097B2),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: _rs(context, 2)),
              child: Icon(
                Icons.star,
                size: _rs(context, 20),
                color: const Color(0xFFFFC107),
              ),
            ),
          ),
        ),
        SizedBox(height: _rs(context, 6)),
        Text(
          'Rate the application',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: _rs(context, 12),
            color: const Color(0xFF6D758F),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Column(
      children: [
        _buildTile(
          context: context,
          icon: Icons.description_outlined,
          title: 'Terms and Conditions',
          onTap: () => Navigator.pushNamed(context, '/terms-and-conditions'),
        ),
        _buildTile(
          context: context,
          icon: Icons.info_outline,
          title: 'About the application',
          onTap: () => Navigator.pushNamed(context, '/about'),
        ),
        _buildTile(
          context: context,
          icon: Icons.help_outline,
          title: 'Frequently asked Questions',
          onTap: () => Navigator.pushNamed(context, '/faq'),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Share.share('Check out OneConnect - your one-stop community app! Download now.');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.share_outlined,
            size: _rs(context, 24),
            color: const Color(0xFF3195AB),
          ),
          SizedBox(width: _rs(context, 8)),
          Text(
            'Share the application',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: _rs(context, 14),
              color: const Color(0xFF272727),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportActions(BuildContext context) {
    return Column(
      children: [
        _buildTile(
          context: context,
          icon: Icons.data_usage_outlined,
          title: 'Data Usage policy',
          onTap: () {
            Navigator.pushNamed(context, '/privacy-policy');
          },
        ),
        _buildTile(
          context: context,
          icon: Icons.support_agent_outlined,
          title: 'Contact us',
          onTap: () async {
            final url = Uri.parse('mailto:support@oneconnect.pk');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
        _buildTile(
          context: context,
          icon: Icons.delete_outline,
          title: 'Delete Account',
          onTap: () => _showDeleteAccountSheet(context),
        ),
      ],
    );
  }

  void _showDeleteAccountSheet(BuildContext context) {
    final double s = _rs(context, 1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_rs(context, 24)),
                  topRight: Radius.circular(_rs(context, 24)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rs(context, 20),
                    vertical: _rs(context, 12),
                  ),
                  child: ListView(
                    controller: controller,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: _rs(context, 32),
                            height: _rs(context, 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF3F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: const Color(0xFF19213D),
                              size: _rs(context, 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _rs(context, 12)),
                      // Warning icon
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/typcn_warning-outline.svg',
                          width: _rs(context, 40),
                          height: _rs(context, 40),
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(height: _rs(context, 12)),
                      // Title
                      Text(
                        'Permanently delete\nmy account',
                        style: GoogleFonts.inter(
                          fontSize: _rs(context, 24),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: _rs(context, 10)),
                      // Paragraphs
                      Text(
                        'Deleting your account is permanent and cannot be reversed. Your profile, media, comments and reviews will be deleted.',
                        style: GoogleFonts.inter(
                          fontSize: _rs(context, 13),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF374151),
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: _rs(context, 8)),
                      Text(
                        'Deleting your account is permanent and cannot be reversed. Your profile, media, comments and reviews will be deleted.',
                        style: GoogleFonts.inter(
                          fontSize: _rs(context, 13),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF374151),
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: _rs(context, 14)),
                      // Deactivate Account button (filled)
                      SizedBox(
                        width: double.infinity,
                        height: _rs(context, 44),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3AA6BD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_rs(context, 10)),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Deactivate Account'),
                                content: const Text('Are you sure you want to deactivate your account?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Provider.of<AuthProvider>(context, listen: false).logout().then((_) {
                                        if (context.mounted) {
                                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Account deactivated for this session')),
                                          );
                                        }
                                      });
                                    },
                                    child: const Text('Deactivate'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'Deactivate Account',
                            style: GoogleFonts.inter(
                              fontSize: _rs(context, 13),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _rs(context, 10)),
                      // Delete Account button (outlined)
                      SizedBox(
                        width: double.infinity,
                        height: _rs(context, 44),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF3AA6BD), width: s),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_rs(context, 10)),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final success = await authProvider.deleteAccount();
                                      if (!context.mounted) return;
                                      if (success) {
                                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Account deleted')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(authProvider.error ?? 'Failed to delete account')),
                                        );
                                      }
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'Delete Account',
                            style: GoogleFonts.inter(
                              fontSize: _rs(context, 13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF156385),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}



