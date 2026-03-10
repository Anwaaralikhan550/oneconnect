import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../utils/profile_image_picker.dart';

class PushNotificationSettingsScreen extends StatefulWidget {
  const PushNotificationSettingsScreen({super.key});

  @override
  State<PushNotificationSettingsScreen> createState() => _PushNotificationSettingsScreenState();
}

class _PushNotificationSettingsScreenState extends State<PushNotificationSettingsScreen> {
  final UserService _userService = UserService();
  // General Updates switches
  bool soundEnabled = true;
  bool vibrateEnabled = true;
  
  // Updates and Promotions switches
  bool emailUpdatesEnabled = true;
  bool smsUpdatesEnabled = false;
  bool pushUpdatesEnabled = true;
  
  // Reminders switches
  bool emailRemindersEnabled = true;
  bool smsRemindersEnabled = false;
  bool pushRemindersEnabled = true;

  File? _profileImage;
  bool _isLoadingPrefs = true;

  // Responsive helpers
  double _sw(BuildContext context) => MediaQuery.of(context).size.width;
  double _rs(BuildContext context, double design) => (_sw(context) / 390.0) * design;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              _buildHeader(context),
              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: _rs(context, 18)),
                      _buildProfileSection(context),
                      SizedBox(height: _rs(context, 15)),
                      _isLoadingPrefs
                          ? Padding(
                              padding: EdgeInsets.only(top: _rs(context, 40)),
                              child: const Center(child: CircularProgressIndicator()),
                            )
                          : _buildMainSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bell icon positioned at top
          Positioned(
            left: 0,
            right: 0,
            top: _rs(context, 130),
            child: Center(
              child: SvgPicture.string(
                '''<svg width="32" height="38" viewBox="0 0 32 38" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 4C10.48 4 6 8.48 6 14V20L2 24V26H30V24L26 20V14C26 8.48 21.52 4 16 4Z" fill="#FFCD29"/>
                <path d="M18 30H14C14 31.1 14.9 32 16 32C17.1 32 18 31.1 18 30Z" fill="#FFCD29"/>
                </svg>''',
                width: _rs(context, 32),
                height: _rs(context, 38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _userService.getNotificationPreferences();
      if (!mounted) return;
      setState(() {
        soundEnabled = prefs['notifySound'] ?? soundEnabled;
        vibrateEnabled = prefs['notifyVibrate'] ?? vibrateEnabled;
        emailUpdatesEnabled = prefs['notifyEmailUpdates'] ?? emailUpdatesEnabled;
        smsUpdatesEnabled = prefs['notifySmsUpdates'] ?? smsUpdatesEnabled;
        pushUpdatesEnabled = prefs['notifyPushUpdates'] ?? pushUpdatesEnabled;
        emailRemindersEnabled = prefs['notifyEmailReminders'] ?? emailRemindersEnabled;
        smsRemindersEnabled = prefs['notifySmsReminders'] ?? smsRemindersEnabled;
        pushRemindersEnabled = prefs['notifyPushReminders'] ?? pushRemindersEnabled;
        _isLoadingPrefs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingPrefs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load preferences')),
      );
    }
  }

  Future<void> _savePreferences() async {
    await _userService.updateNotificationPreferences({
      'notifySound': soundEnabled,
      'notifyVibrate': vibrateEnabled,
      'notifyEmailUpdates': emailUpdatesEnabled,
      'notifySmsUpdates': smsUpdatesEnabled,
      'notifyPushUpdates': pushUpdatesEnabled,
      'notifyEmailReminders': emailRemindersEnabled,
      'notifySmsReminders': smsRemindersEnabled,
      'notifyPushReminders': pushRemindersEnabled,
    });
  }

  Future<void> _updatePrefSafely({
    required bool newValue,
    required bool oldValue,
    required void Function(bool) applyValue,
  }) async {
    applyValue(newValue);
    try {
      await _savePreferences();
    } catch (_) {
      applyValue(oldValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save preferences')),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _rs(context, 150),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
              SizedBox(width: _rs(context, 15)),
              // Title - Centered
              Expanded(
                child: Center(
                  child: Text(
                    'Push Notification',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: _rs(context, 20),
                      color: const Color(0xFF515151),
                      letterSpacing: -0.28,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 15)),
              // Placeholder for symmetry
              SizedBox(
                width: _rs(context, 35),
                height: _rs(context, 35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final profileUrl = user?.profilePhotoUrl;
        return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
      child: Container(
        padding: EdgeInsets.fromLTRB(_rs(context, 15), _rs(context, 10), _rs(context, 15), _rs(context, 10)),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(_rs(context, 10)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final File? image = await ProfileImagePicker.showImageSourceDialog(context);
                if (image != null) {
                  final url = await Provider.of<AuthProvider>(context, listen: false).uploadProfilePhoto(image.path);
                  if (url != null) {
                    setState(() {
                      _profileImage = image;
                    });
                  }
                }
              },
              child: Container(
                width: _rs(context, 47.77),
                height: _rs(context, 47.77),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF044870), width: _rs(context, 2)),
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : (profileUrl != null && profileUrl.startsWith('http'))
                          ? DecorationImage(
                              image: NetworkImage(profileUrl),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/profile_image.png'),
                              fit: BoxFit.cover,
                            ),
                ),
              ),
            ),
            SizedBox(width: _rs(context, 12)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: _rs(context, 10), vertical: _rs(context, 5)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_rs(context, 10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: _rs(context, 14),
                            height: 1.2,
                            letterSpacing: 0.112,
                            color: const Color(0xFF353535),
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: _rs(context, 14),
                            height: 1.3,
                            letterSpacing: 0.168,
                            color: const Color(0xFF353535),
                          ),
                        ),
                      ],
                    ),
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
                          fontWeight: FontWeight.w700,
                          fontSize: _rs(context, 12),
                          height: 1.35,
                          letterSpacing: 0.147,
                          color: const Color(0xFFFF6767),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildMainSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
      child: Column(
        children: [
          // General Updates Section
          _buildSectionHeader(context, 'General Updates', 'Always be notified by sound, vibrate feature and pop-up notification on your mobile. Never miss an update'),
          SizedBox(height: _rs(context, 10)),
          Column(
            children: [
              _buildSwitchItem(context, _buildSoundIcon(context), 'Sound', soundEnabled, (value) => setState(() => soundEnabled = value), true, false),
              _buildSwitchItem(context, _buildVibrateIcon(context), 'Vibrate', vibrateEnabled, (value) => setState(() => vibrateEnabled = value), false, true),
            ],
          ),
          SizedBox(height: _rs(context, 15)),
          // Updates and Promotions Section
          _buildSectionHeader(context, 'Updates and Promotions', 'Be the first to know about new application features, promotions and deals'),
          SizedBox(height: _rs(context, 10)),
          Column(
            children: [
              _buildSwitchItem(context, _buildEmailIcon(context), 'Email', emailUpdatesEnabled, (value) => setState(() => emailUpdatesEnabled = value), true, false),
              _buildSwitchItem(context, _buildSMSIcon(context), 'SMS', smsUpdatesEnabled, (value) => setState(() => smsUpdatesEnabled = value), false, false),
              _buildSwitchItem(context, _buildPushNotificationIcon(context), 'Push Notification', pushUpdatesEnabled, (value) => setState(() => pushUpdatesEnabled = value), false, true),
            ],
          ),
          SizedBox(height: _rs(context, 15)),
          // Rating Section
          _buildRatingSection(context),
          SizedBox(height: _rs(context, 15)),
          // Reminders Section
          _buildSectionHeader(context, 'Reminders', 'Be the first to know about new application features, promotions and deals'),
          SizedBox(height: _rs(context, 10)),
          Column(
            children: [
              _buildSwitchItem(context, _buildEmailIcon(context), 'Email', emailRemindersEnabled, (value) => setState(() => emailRemindersEnabled = value), true, false),
              _buildSwitchItem(context, _buildSMSIcon(context), 'SMS', smsRemindersEnabled, (value) => setState(() => smsRemindersEnabled = value), false, false),
              _buildSwitchItem(context, _buildPushNotificationIcon(context), 'Push Notification', pushRemindersEnabled, (value) => setState(() => pushRemindersEnabled = value), false, true),
            ],
          ),
          SizedBox(height: _rs(context, 30)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: _rs(context, 20),
            height: 1.21,
            color: Colors.black,
          ),
        ),
        SizedBox(height: _rs(context, 6)),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: _rs(context, 13),
            height: 1.21,
            color: Colors.black,
          ),
        ),
      ],
    );
  }


  Widget _buildRatingSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => 
            Container(
              width: _rs(context, 20),
              height: _rs(context, 20),
              margin: EdgeInsets.symmetric(horizontal: _rs(context, 2.5)),
              child: SvgPicture.string(
                '''<svg width="19.02" height="18.09" viewBox="0 0 19.02 18.09" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.51 0.42L11.73 6.09H18.53L13.01 9.89L15.23 15.56L9.51 11.76L3.79 15.56L6.01 9.89L0.49 6.09H7.29L9.51 0.42Z" fill="#FFCD29"/>
                </svg>''',
                width: _rs(context, 19.02),
                height: _rs(context, 18.09),
              ),
            ),
          ),
        ),
        SizedBox(height: _rs(context, 1)),
        Text(
          'Rate the application',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: _rs(context, 12),
            height: 1.21,
            color: const Color(0xFF353535),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(BuildContext context, Widget icon, String title, bool value, ValueChanged<bool> onChanged, bool isFirst, bool isLast) {
    return Container(
      width: double.infinity,
      height: _rs(context, 40),
      padding: EdgeInsets.fromLTRB(_rs(context, 15), _rs(context, 6), _rs(context, 15), _rs(context, 6)),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: isFirst
            ? BorderRadius.only(
                topLeft: Radius.circular(_rs(context, 10)),
                topRight: Radius.circular(_rs(context, 10)),
              )
            : isLast
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(_rs(context, 10)),
                    bottomRight: Radius.circular(_rs(context, 10)),
                  )
                : BorderRadius.zero,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: _rs(context, 15)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: _rs(context, 14),
                height: 1.21,
                color: const Color(0xFF353535),
              ),
            ),
          ),
          _buildCustomSwitch(context, value, (v) async {
            await _updatePrefSafely(
              newValue: v,
              oldValue: value,
              applyValue: (val) => onChanged(val),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(BuildContext context, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: _rs(context, 45),
        height: _rs(context, 24),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF02A6C3) : const Color(0xFFCDCDCD),
          borderRadius: BorderRadius.circular(_rs(context, 25)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _rs(context, 18),
            height: _rs(context, 18),
            margin: EdgeInsets.all(_rs(context, 3)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundIcon(BuildContext context) {
    return SizedBox(
      width: _rs(context, 25),
      height: _rs(context, 25),
      child: SvgPicture.asset(
        'assets/icons/tdesign_sound.svg',
        width: _rs(context, 25),
        height: _rs(context, 25),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildVibrateIcon(BuildContext context) {
    return SizedBox(
      width: _rs(context, 25),
      height: _rs(context, 25),
      child: SvgPicture.asset(
        'assets/icons/ph_vibrate.svg',
        width: _rs(context, 25),
        height: _rs(context, 25),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildEmailIcon(BuildContext context) {
    return SizedBox(
      width: _rs(context, 25),
      height: _rs(context, 25),
      child: SvgPicture.asset(
        'assets/icons/Email.svg',
        width: _rs(context, 25),
        height: _rs(context, 25),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSMSIcon(BuildContext context) {
    return SizedBox(
      width: _rs(context, 25),
      height: _rs(context, 25),
      child: SvgPicture.asset(
        'assets/icons/material-symbols_sms-outline-sharp.svg',
        width: _rs(context, 25),
        height: _rs(context, 25),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPushNotificationIcon(BuildContext context) {
    return SizedBox(
      width: _rs(context, 25),
      height: _rs(context, 25),
      child: SvgPicture.asset(
        'assets/icons/basil_notification-on-outline.svg',
        width: _rs(context, 25),
        height: _rs(context, 25),
        fit: BoxFit.contain,
      ),
    );
  }
}
