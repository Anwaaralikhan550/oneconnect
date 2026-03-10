import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpMemberScreen extends StatefulWidget {
  const SignUpMemberScreen({super.key});

  @override
  State<SignUpMemberScreen> createState() => _SignUpMemberScreenState();
}

class _SignUpMemberScreenState extends State<SignUpMemberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneFocused = false;
  Country _selectedCountry = Country(
    phoneCode: '92',
    countryCode: 'PK',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Pakistan',
    example: 'Pakistan',
    displayName: 'Pakistan (PK) [+92]',
    displayNameNoCountryCode: 'Pakistan',
    e164Key: '',
  );

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handleGoogleSignUp() {
    Navigator.pushNamed(context, '/email-password-signup');
  }

  void _handleAppleSignUp() {
    Navigator.pushNamed(context, '/email-password-signup');
  }

  void _handleEmailPasswordSignUp() {
    Navigator.pushNamed(context, '/email-password-signup');
  }

  void _handleContinue() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to email/password signup screen
    Navigator.pushNamed(context, '/email-password-signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with background image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Header.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(55),
                    bottomRight: Radius.circular(55),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Headline
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Pakistan\'s #1 Community Services Mobile Application',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your go-to app for seamless community services in Pakistan!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: Colors.black.withOpacity( 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 25),
              
              // Sign up divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                    SizedBox(width: 22),
                    Text(
                      'Sign up',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity( 0.75),
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Phone number input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isPhoneFocused ? Color(0xFF2388FF) : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: _isPhoneFocused
                        ? [
                            BoxShadow(
                              color: Color(0xFF2388FF).withOpacity( 0.15),
                              blurRadius: 7,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Country selector
                        InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                              countryListTheme: CountryListThemeData(
                                flagSize: 25,
                                backgroundColor: Colors.white,
                                textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                                bottomSheetHeight: 500,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                inputDecoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText: 'Start typing to search',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color(0xFF8C98A8).withOpacity( 0.2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                _selectedCountry.flagEmoji,
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _selectedCountry.countryCode,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF19213D),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: Color(0xFF19213D),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Phone input
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            enableInteractiveSelection: false,
                            contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: '+${_selectedCountry.phoneCode} (000) 000-0000',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF19213D).withOpacity( 0.5),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF19213D),
                            ),
                          ),
                        ),
                        // Question icon
                        Icon(
                          Icons.help_outline,
                          size: 20,
                          color: Color(0xFF19213D),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 25),
              
              // Continue button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF0097B2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(0xFF008EA8),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0097B2).withOpacity( 0.0),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _handleContinue();
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Or divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'or using other method',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF545454),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Social sign-in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Sign-In Button
                  _buildSocialButton(
                    onTap: () {
                      _handleGoogleSignUp();
                    },
                    child: SvgPicture.asset(
                      'assets/images/devicon_google.svg',
                      width: 25,
                      height: 25,
                    ),
                  ),
                  SizedBox(width: 55),
                  // Apple Sign-In Button
                  _buildSocialButton(
                    onTap: () {
                      _handleAppleSignUp();
                    },
                    child: SvgPicture.asset(
                      'assets/images/apple_icon.svg',
                      width: 29,
                      height: 29,
                      colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 55),
                  // Email/Password Sign-In Button
                  _buildSocialButton(
                    onTap: () {
                      _handleEmailPasswordSignUp();
                    },
                    child: SvgPicture.asset(
                      'assets/images/email_icon.svg',
                      width: 27,
                      height: 27,
                      colorFilter: ColorFilter.mode(Color(0xFF0097B2), BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 25),
              
              // Terms of service and login link
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Already have account section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3F3F3F),
                          ),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF237B98),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 15),
                    
                    Text(
                      'By continuing, you agree to our',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111214).withOpacity( 0.8),
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/terms-and-conditions');
                          },
                          child: Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontFamily: 'Nourd',
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/privacy-policy');
                          },
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontFamily: 'Nourd',
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/privacy-policy');
                          },
                          child: Text(
                            'Content Policies',
                            style: TextStyle(
                              fontFamily: 'Nourd',
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
    );
  }



  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: 55,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(child: child),
        ),
      ),
    );
  }

}

