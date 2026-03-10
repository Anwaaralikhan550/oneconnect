import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  double _rw(BuildContext context, double d) =>
      (MediaQuery.of(context).size.width / 390) * d;
  double _rh(BuildContext context, double d) =>
      (MediaQuery.of(context).size.height / 844) * d;
  double _rf(BuildContext context, double d) =>
      (MediaQuery.of(context).size.width / 390) * d;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header (matches service_provider_detail_screen style)
              Container(
                width: double.infinity,
                height: _rh(context, 150),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(_rw(context, 50)),
                    bottomRight: Radius.circular(_rw(context, 50)),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _rw(context, 15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: _rw(context, 35),
                            height: _rw(context, 35),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3195AB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: _rw(context, 18),
                            ),
                          ),
                        ),
                        SizedBox(width: _rw(context, 15)),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              'Privacy Policy',
                              style: GoogleFonts.inter(
                                fontSize: _rf(context, 20),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF515151),
                                letterSpacing: -0.28,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(width: _rw(context, 15)),
                        // Right placeholder (kept empty for symmetry)
                        SizedBox(
                          width: _rw(context, 35),
                          height: _rw(context, 35),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rw(context, 18),
                    vertical: _rh(context, 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(
                        context,
                        'Data Collection',
                        'At OneConnect, we respect your privacy and are committed to protecting your personal information. We collect only the data necessary to provide and improve our services, such as your name, email, and usage details.',
                      ),
                      _section(
                        context,
                        'Data Usage',
                        'Your information will never be sold or shared with third parties except as required by law or to deliver our services securely.',
                      ),
                      _section(
                        context,
                        'Data Security',
                        'We use standard security measures to safeguard your data against unauthorized access.',
                      ),
                      _section(
                        context,
                        'User Acceptance',
                        'By using OneConnect, you agree to this policy and consent to the collection and use of information as described. You may contact us anytime to request access, correction, or deletion of your data. This policy is reviewed regularly and may be updated, with changes communicated within the app.',
                      ),
                      SizedBox(height: _rh(context, 16)),
                      SizedBox(
                        width: double.infinity,
                        height: _rh(context, 52),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0097B2),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(_rw(context, 8)),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'I accept the privacy policy',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: _rf(context, 14),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _rh(context, 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top centered decorative icon (ppp.svg)
          Positioned(
            left: 0,
            right: 0,
            top: _rh(context, 130),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/ppp.svg',
                width: _rw(context, 30),
                height: _rw(context, 30),
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFC107),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: _rh(context, 14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: _rf(context, 16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202020),
            ),
          ),
          SizedBox(height: _rh(context, 6)),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: _rf(context, 13),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF303030),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}


