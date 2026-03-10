import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive calculations based on Figma design (390x844)
    final designWidth = 390.0;
    final designHeight = 844.0;
    final scaleWidth = screenWidth / designWidth;
    final scaleHeight = screenHeight / designHeight;
    final scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
         gradient: RadialGradient(
           colors: [
             Color(0xff5DE0E6),
             Color(0xff054870),
           ],
           center: Alignment.center,
           radius: 1.2,
           stops: [0.3, 1.0],
         ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top section with logos - matching Figma Frame 4
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 50 * scale, // Moved logo further up
                        left: 20 * scale,
                        right: 20 * scale,
                      ),
                      child: Column(
                        children: [
                          // OneConnect graphic text (275x62)
                          SizedBox(
                            width: 450 * scale,
                            height: 82 * scale,
                            child: Image.asset(
                              'assets/images/oneconnect_text_graphic.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback OneConnect text graphic
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'OneConnect',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 45 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 35 * scale), // Increased gap to move logo lower

                          // Main image - larger size, no shadow, no background
                          SizedBox(
                            width: 220 * scale, // Increased size
                            height: 220 * scale,
                            child: Image.asset(
                              'assets/images/oneconnect_logo_circle.png',
                              width: 220 * scale,
                              height: 220 * scale,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: 220 * scale,
                                  height: 220 * scale,
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 110 * scale,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom white section (Main Content frame)
                  Container(
                    width: double.infinity,
                    height: 400 * scale, // Figma exact height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25 * scale),
                        topRight: Radius.circular(25 * scale),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 15 * scale),
                      child: Column(
                        children: [
                          // Header with signup text - aligned to left, no backgrounds
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 25 * scale),
                              padding: EdgeInsets.only(top: 15 * scale, bottom: 5 * scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Signup title - left aligned, no background
                                  Text(
                                    'Signup',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 28 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      letterSpacing: 0.1,
                                      height: 0.714,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  
                                  SizedBox(height: 10 * scale),
                                  
                                  // Subtitle text - completely clean, no background or decoration
                                  Text(
                                    'Signup to connect to convenience',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 15 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF191919),
                                      letterSpacing: 0.1,
                                      height: 1.667,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 25 * scale),
                          
                          // Member button (Frame 414)
                          Container(
                            width: 324 * scale,
                            height: 50 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3499AF),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/member-signup');
                                },
                                borderRadius: BorderRadius.circular(8 * scale),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Member',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 17 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 10 * scale),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 14.65 * scale, // Exact Figma size
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Or divider
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 25 * scale),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 129.24 * scale,
                                  height: 1,
                                  color: const Color(0xFF2F2F2F),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 22 * scale),
                                  child: Text(
                                    'Or',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      height: 1.21,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 125 * scale,
                                  height: 1,
                                  color: const Color(0xFF2F2F2F),
                                ),
                              ],
                            ),
                          ),
                          //
                          // Partner button (Frame 415)
                          Container(
                            width: 324 * scale,
                            height: 50 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3499AF),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/partner-step1');
                                },
                                borderRadius: BorderRadius.circular(8 * scale),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Partner',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 10 * scale),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 14.65 * scale, // Exact Figma size
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Bottom login section (Frame 191)
                          SizedBox(
                            width: 260 * scale,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 3 * scale,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xCC111214),
                                    height: 1.172,
                                  ),
                                ),
                                Text(
                                  'Log In as',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2B2B2B),
                                    height: 1.172,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Text(
                                    'Member',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF3499AF),
                                      height: 1.172,
                                    ),
                                  ),
                                ),
                                Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2B2B2B),
                                    height: 1.172,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/partner-login');
                                  },
                                  child: Text(
                                    'Partner',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF3499AF),
                                      height: 1.172,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 15 * scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}