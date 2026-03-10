import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
              // Header styled like other detail screens
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
                    padding: EdgeInsets.symmetric(horizontal: _rw(context, 15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button
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
                              'About the App',
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
                        // Placeholder for symmetry
                        SizedBox(
                          width: _rw(context, 35),
                          height: _rw(context, 35),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rw(context, 18),
                    vertical: _rh(context, 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _bulletSection(
                        context,
                        'assets/icons/a1.svg',
                        'What is OneConnect',
                        'OneConnect is a powerful mobile application designed to bring small and medium enterprises (SMEs), businesses, service providers, and community amenities together on one platform. It creates a digital ecosystem that simplifies access to services, resources, and opportunities for growth.',
                      ),
                      _bulletSection(
                        context,
                        'assets/icons/a2.svg',
                        'Connecting Businesses and Communities',
                        'Our platform bridges the gap between local businesses and the communities they serve. From essential services to everyday amenities, OneConnect makes it easier for users to discover, connect, and collaborate within their own community.',
                      ),
                      _bulletSection(
                        context,
                        'assets/icons/a3.svg',
                        'Empowering SMEs and Service Providers',
                        'OneConnect provides SMEs and service providers with the visibility and tools they need to thrive in today\'s digital economy. By joining the platform, businesses can showcase their offerings, reach more customers, and build stronger connections.',
                      ),
                      _bulletSection(
                        context,
                        'assets/icons/a4.svg',
                        'Secure and Reliable Experience',
                        'We prioritize security, ensuring that all interactions and transactions within OneConnect are safe and protected with industry-standard measures.',
                      ),

                      SizedBox(height: _rh(context, 24)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top decorative icon (use the provided ppp.svg for now)
          Positioned(
            left: 0,
            right: 0,
            top: _rh(context, 130),
            child: Center(
              child: Image.asset(
                'assets/images/oneconnect_logo.png',
                width: _rw(context, 160),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletSection(BuildContext context, String iconPath, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: _rh(context, 14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _rh(context, 4)),
            child: SvgPicture.asset(
              iconPath,
              width: _rw(context, 24),
              height: _rw(context, 24),
            ),
          ),
          SizedBox(width: _rw(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: _rf(context, 15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202020),
                  ),
                ),
                SizedBox(height: _rh(context, 4)),
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
          ),
        ],
      ),
    );
  }
}


