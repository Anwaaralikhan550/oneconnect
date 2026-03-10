import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PartnerStep6Screen extends StatefulWidget {
  const PartnerStep6Screen({super.key});

  @override
  State<PartnerStep6Screen> createState() => _PartnerStep6ScreenState();
}

class _PartnerStep6ScreenState extends State<PartnerStep6Screen> {
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    if (_isSubmitting) return;

    final data = (ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?) ?? {};

    setState(() => _isSubmitting = true);
    try {
      // Build registration payload
      final payload = <String, dynamic>{
        'businessName': data['businessName'] ?? '',
        'ownerFullName': data['ownerFullName'] ?? '',
        'businessEmail': data['businessEmail'] ?? '',
        'password': data['password'] ?? '',
        'businessType': data['businessType'] ?? 'OTHER',
        if (data['address'] != null) 'address': data['address'],
        if (data['area'] != null) 'area': data['area'],
        if (data['city'] != null) 'city': data['city'],
        'country': data['country'] ?? 'Pakistan',
        'phones': [
          {
            'phoneNumber': data['phone'] ?? '',
            'countryCode': data['countryCode'] ?? '+92',
            'isPrimary': true,
          }
        ],
      };

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.partnerRegister(payload);

      if (!mounted) return;

      if (result != null) {
        final businessId = result['partner']?['businessId'] ?? '';
        Navigator.pushNamed(context, '/partner-step7', arguments: {
          'businessId': businessId,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive calculations based on screen size
    final titleFontSize = screenWidth * 0.075; // Responsive title size
    final descriptionFontSize = screenWidth * 0.05; // Responsive description size
    final buttonHeight = screenHeight * 0.065; // 6.5% of screen height
    final imageSize = screenHeight * 0.3; // 30% of screen height
    final verticalSpacing = screenHeight * 0.04; // 4% for vertical spacing

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0x26000000), // rgba(0, 0, 0, 0.15)
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.07, // 7% horizontal padding only
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title - responsive width
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.83,
                      ),
                      margin: EdgeInsets.only(bottom: verticalSpacing),
                      child: Text(
                        'We are Reviewing your application',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: titleFontSize.clamp(26.0, 34.0),
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.2102272851126534, // Exact Figma line height
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Review illustration - responsive size without shadow
                    Container(
                      width: imageSize.clamp(220.0, 320.0),
                      height: imageSize.clamp(220.0, 320.0),
                      margin: EdgeInsets.only(bottom: verticalSpacing),
                      child: Image.asset(
                        'assets/images/review_illustration.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  color: const Color(0xFF3499AF),
                                  size: imageSize * 0.3,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Under Review',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: descriptionFontSize * 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3499AF),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Description text container with exact Figma styling
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.085),
                      child: Text(
                        'Your account is being reviewed and will receive your login credentials by email',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: descriptionFontSize.clamp(17.0, 22.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2200000551011827, // Exact Figma line height
                          letterSpacing: -0.275, // -1.5555555621782937%
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button section
            Container(
              width: double.infinity,
              height: buttonHeight.clamp(50.0, 64.0),
              margin: EdgeInsets.fromLTRB(
                screenWidth * 0.07,
                0,
                screenWidth * 0.07,
                screenHeight * 0.03,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3499AF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSubmitting ? null : _submitRegistration,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: (buttonHeight * 0.3).clamp(16.0, 18.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
