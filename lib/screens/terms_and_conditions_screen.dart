import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
              // Header like service_provider_detail_screen
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
                        Expanded(
                          child: Center(
                            child: Text(
                              'Terms and Conditions',
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
                        SizedBox(
                          width: _rw(context, 35),
                          height: _rw(context, 35),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
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
                        'User Agreement',
                        'By downloading or using OneConnect, you agree to these Terms and Conditions.',
                      ),
                      _section(
                        context,
                        'Application Usage',
                        'OneConnect is provided for personal and lawful use only. You must not misuse the app or attempt to disrupt its services.',
                      ),
                      _section(
                        context,
                        'Intellectual Property',
                        'All content, trademarks, and materials in the app are the property of OneConnect and may not be copied or redistributed without permission.',
                      ),
                      _section(
                        context,
                        'Liability',
                        'While we aim to keep the app reliable, we do not guarantee uninterrupted or error-free service and are not liable for losses caused by its use. You are responsible for keeping your login information secure.',
                      ),
                      _section(
                        context,
                        'Updates',
                        'OneConnect may update or modify these terms at any time, and continued use of the app means you accept the updated terms.',
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
                            'I understand the terms and conditions',
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


