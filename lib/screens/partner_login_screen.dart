import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/token_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final TextEditingController _businessIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _businessIdFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isBusinessIdFocused = false;
  bool _isPasswordFocused = false;
  bool _isPasswordVisible = false;
  bool _showBusinessIdError = false;
  bool _showPasswordError = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _businessIdFocusNode.addListener(() {
      setState(() {
        _isBusinessIdFocused = _businessIdFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _businessIdController.dispose();
    _passwordController.dispose();
    _businessIdFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Design is based on 390x844 frame
    final designWidth = 390.0;
    final designHeight = 844.0;
    final scaleWidth = screenWidth / designWidth;
    final scaleHeight = screenHeight / designHeight;
    final scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

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
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              // Header and Profile section with overlap
              _buildHeaderAndProfile(scale),

              SizedBox(height: 35 * scale),

              // Login Account section
              Expanded(
                child: _buildLoginAccount(scale),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndProfile(double scale) {
    return Column(
      children: [
        // Header with curved background
        Container(
          width: 390 * scale,
          height: 164 * scale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(75 * scale),
              bottomRight: Radius.circular(75 * scale),
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/partner_header_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(75 * scale),
                bottomRight: Radius.circular(75 * scale),
              ),
            ),
            padding: EdgeInsets.only(top: 40 * scale, bottom: 20 * scale),
            child: Center(
              child: _buildMainLogo(scale),
            ),
          ),
        ),

        // Profile section with -22px gap (overlapping)
        Transform.translate(
          offset: Offset(0, -22 * scale),
          child: Container(
            width: 110 * scale,
            height: 45 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8 * scale),
              image: const DecorationImage(
                image: AssetImage('assets/images/partner_login_profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainLogo(double scale) {
    return Container(
      width: 275 * scale,
      height: 62 * scale,
      margin: EdgeInsets.symmetric(horizontal: 10 * scale),
      child: SvgPicture.asset(
        'assets/images/oneconnect_logo.svg',
        width: 275 * scale,
        height: 62 * scale,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        allowDrawingOutsideViewBox: false,
        placeholderBuilder: (context) {
          return Center(
            child: Text(
              'OneConnect',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3499AF),
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginAccount(double scale) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 25 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and subtitle section
            _buildTitleSection(scale),

            SizedBox(height: 20 * scale),

            // Input fields section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: _buildInputSection(scale),
            ),

            SizedBox(height: 20 * scale),

            // Remember me section
            _buildRememberMeSection(scale),

            SizedBox(height: 20 * scale),

            // Login button
            _buildLoginButton(scale),

            SizedBox(height: 12 * scale),

            // Sign up text
            _buildSignUpText(scale),

            SizedBox(height: 20 * scale),

            // Terms of Service section
            _buildTermsSection(scale),

            SizedBox(height: 10 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(double scale) {
    return Column(
      children: [
        // "Login Account" title
        SizedBox(
          width: double.infinity,
          child: Text(
            'Login Account',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.21,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 10 * scale),

        // "Please login with your Business ID" subtitle
        Text(
          'Please login with your Business ID',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: Colors.black.withOpacity( 0.75),
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputSection(double scale) {
    return Column(
      children: [
        // Business ID Input Field
        _buildBusinessIdField(scale),

        SizedBox(height: 20 * scale),

        // Password Input Field
        _buildPasswordField(scale),
      ],
    );
  }

  Widget _buildBusinessIdField(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10 * scale),
          child: Text(
            'Business ID',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: Color(0xFF19213D),
            ),
          ),
        ),
        
        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: _showBusinessIdError 
                  ? Colors.red 
                  : (_isBusinessIdFocused 
                      ? Color(0xFF6D758F) 
                      : (_businessIdController.text.isNotEmpty 
                          ? Color(0xFF6D758F) 
                          : Color(0xFFC5CBDE))),
              width: _showBusinessIdError ? 1 : (_isBusinessIdFocused ? 1 : 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF19213D).withOpacity(0.11),
                blurRadius: 2 * scale,
                offset: Offset(0, 0.5 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            child: Row(
              children: [
                // Error icon (red circle with white X) or Business icon
                _showBusinessIdError && _businessIdController.text.isEmpty
                    ? Container(
                        width: 20 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14 * scale,
                          color: Colors.red,
                        ),
                      )
                    : Icon(
                        Icons.business,
                        size: 20 * scale,
                        color: _businessIdController.text.isNotEmpty 
                            ? Color(0xFF19213D) 
                            : Color(0xFF6D758F),
                      ),
                SizedBox(width: 10 * scale),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: _businessIdController,
                    focusNode: _businessIdFocusNode,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: 'Enter your Business ID',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6D758F),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF19213D),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (_showBusinessIdError && value.isNotEmpty) {
                          _showBusinessIdError = false;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10 * scale),
          child: Text(
            'Password',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: Color(0xFF19213D),
            ),
          ),
        ),
        
        // Password field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: _showPasswordError 
                  ? Colors.red 
                  : (_isPasswordFocused 
                      ? Color(0xFF6D758F) 
                      : Color(0xFFC5CBDE)),
              width: _showPasswordError ? 1 : (_isPasswordFocused ? 1 : 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF19213D).withOpacity(0.11),
                blurRadius: 2 * scale,
                offset: Offset(0, 0.5 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            child: Row(
              children: [
                // Error icon (red circle with white X) or Lock icon
                _showPasswordError && _passwordController.text.isEmpty
                    ? Container(
                        width: 20 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14 * scale,
                          color: Colors.red,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/images/lock12.svg',
                        width: 20 * scale,
                        height: 20 * scale,
                        colorFilter: ColorFilter.mode(
                          Color(0xFF9AA0B6),
                          BlendMode.srcIn,
                        ),
                      ),
                SizedBox(width: 10 * scale),
                
                // Password field
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9AA0B6),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF19213D),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (_showPasswordError && value.isNotEmpty) {
                          _showPasswordError = false;
                        }
                      });
                    },
                  ),
                ),
                
                // Eye icon - same icon, toggle visibility on tap
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/images/CloseEye.svg',
                    width: 20 * scale,
                    height: 20 * scale,
                    colorFilter: ColorFilter.mode(
                      Color(0xFF9AA0B6),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Help text
        SizedBox(height: 4 * scale),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14 * scale,
              color: Color(0xFF6D758F),
            ),
            SizedBox(width: 4 * scale),
            Text(
              '8+ characters with numbers/symbols',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6D758F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRememberMeSection(double scale) {
    return SizedBox(
      width: 340 * scale,
      child: Row(
        children: [
          // Remember me checkbox and text
          GestureDetector(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 20 * scale,
                  height: 20 * scale,
                  decoration: BoxDecoration(
                    color: _rememberMe ? const Color(0xFF3499AF) : Colors.white,
                    border: Border.all(
                      color: _rememberMe ? const Color(0xFF3499AF) : Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4 * scale),
                  ),
                  child: _rememberMe
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14 * scale,
                        )
                      : null,
                ),
                SizedBox(width: 8 * scale),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Forgot password link
          InkWell(
            onTap: _handleForgotPassword,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: Color(0xFF237B98),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(double scale) {
    return Container(
      width: 324 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF3499AF),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handlePartnerLogin,
          borderRadius: BorderRadius.circular(8 * scale),
          child: Center(
            child: Text(
              'Log in to your account',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.26,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText(double scale) {
    return SizedBox(
      width: 340 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity( 0.75),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/partner-step1');
            },
            child: Text(
              'Sign up',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3499AF),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 5 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "By continuing, you agree to our" text
          Text(
            'By continuing, you agree to our',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111214).withOpacity( 0.8),
              height: 1.21,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3 * scale),

          // Terms links row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Terms of Service
              GestureDetector(
                onTap: () {
                  // Navigate to Terms of Service
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.21,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(width: 15 * scale),

              // Privacy Policy
              GestureDetector(
                onTap: () {
                  // Navigate to Privacy Policy
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.21,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(width: 15 * scale),

              // Content Policies
              GestureDetector(
                onTap: () {
                  // Navigate to Content Policies
                },
                child: Text(
                  'Content Policies',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.21,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePartnerLogin() async {
    bool hasError = false;
    
    if (_businessIdController.text.isEmpty) {
      setState(() {
        _showBusinessIdError = true;
      });
      hasError = true;
    } else {
      setState(() {
        _showBusinessIdError = false;
      });
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _showPasswordError = true;
      });
      hasError = true;
    } else {
      setState(() {
        _showPasswordError = false;
      });
    }

    if (hasError) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.partnerLogin(
      businessId: _businessIdController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      await TokenStorage.setRememberMe(_rememberMe);
      if (!mounted) return;
      final status = (authProvider.partner?.status ?? '').toUpperCase();
      if (status == 'APPROVED') {
        _showSnackBar('Partner login successful!', Colors.green);
      } else {
        _showSnackBar('Logged in. Your account is pending approval.', Colors.orange);
      }
      Navigator.pushNamedAndRemoveUntil(context, '/partner-dashboard', (route) => false);
    } else {
      _showSnackBar(authProvider.error ?? 'Login failed', Colors.red);
    }
  }

  void _handleForgotPassword() {
    _showForgotPasswordBottomSheet(context);
  }

  void _showForgotPasswordBottomSheet(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final designWidth = 390.0;
    final scale = screenWidth / designWidth;
    final responsiveScale = scale.clamp(0.8, 1.2);

    final TextEditingController businessIdController = TextEditingController();
    final FocusNode businessIdFocusNode = FocusNode();
    final ValueNotifier<bool> isBusinessIdFocusedNotifier = ValueNotifier<bool>(false);

    businessIdFocusNode.addListener(() {
      isBusinessIdFocusedNotifier.value = businessIdFocusNode.hasFocus;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ValueListenableBuilder<bool>(
              valueListenable: isBusinessIdFocusedNotifier,
              builder: (context, isBusinessIdFocused, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30 * responsiveScale),
                      topRight: Radius.circular(30 * responsiveScale),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20 * responsiveScale),
                            
                            // Back button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                businessIdController.dispose();
                                businessIdFocusNode.dispose();
                              },
                              child: Container(
                                width: 40 * responsiveScale,
                                height: 40 * responsiveScale,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 20 * responsiveScale,
                                  color: Color(0xFF160D1F),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20 * responsiveScale),
                            
                            // Title
                            Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 35 * responsiveScale,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF160D1F),
                                height: 1.14,
                              ),
                            ),
                            
                            SizedBox(height: 15 * responsiveScale),
                            
                            // Description
                            Text(
                              'Enter your Business ID for the verification process, we will send code to your registered email',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15 * responsiveScale,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C2C2C),
                                height: 1.21,
                              ),
                            ),
                            
                            SizedBox(height: 30 * responsiveScale),
                            
                            // Business ID Label
                            Text(
                              'Business ID',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16 * responsiveScale,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF19213D),
                              ),
                            ),
                            
                            SizedBox(height: 10 * responsiveScale),
                            
                            // Business ID Input Field
                            Container(
                              height: 62 * responsiveScale,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16 * responsiveScale),
                                border: Border.all(
                                  color: isBusinessIdFocused 
                                      ? Color(0xFF2388FF) 
                                      : (businessIdController.text.isNotEmpty 
                                          ? Color(0xFF6D758F) 
                                          : Color(0xFFC5CBDE)),
                                  width: isBusinessIdFocused ? 1 : 0.5,
                                ),
                                boxShadow: isBusinessIdFocused
                                    ? [
                                        BoxShadow(
                                          color: Color(0xFF2388FF).withOpacity(0.15),
                                          blurRadius: 7 * responsiveScale,
                                          offset: Offset(0, 4 * responsiveScale),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Color(0xFF19213D).withOpacity(0.11),
                                          blurRadius: 2 * responsiveScale,
                                          offset: Offset(0, 0.5 * responsiveScale),
                                        ),
                                      ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * responsiveScale,
                                ),
                                child: Row(
                                  children: [
                                    // Business icon
                                    Icon(
                                      Icons.business,
                                      size: 20 * responsiveScale,
                                      color: Color(0xFF19213D),
                                    ),
                                    SizedBox(width: 10 * responsiveScale),
                                    
                                    // Text field
                                    Expanded(
                                      child: TextField(
                                        controller: businessIdController,
                                        focusNode: businessIdFocusNode,
                                        enableInteractiveSelection: false,
                                        contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your Business ID',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16 * responsiveScale,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF6D758F),
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16 * responsiveScale,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF19213D),
                                        ),
                                        onChanged: (value) {
                                          setModalState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 30 * responsiveScale),
                            
                            // Continue Button
                            Container(
                              width: double.infinity,
                              height: 48 * responsiveScale,
                              decoration: BoxDecoration(
                                color: Color(0xFF3499AF),
                                borderRadius: BorderRadius.circular(8 * responsiveScale),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (businessIdController.text.isEmpty) {
                                      _showSnackBar('Please enter your Business ID', Colors.red);
                                      return;
                                    }
                                    try {
                                      await Provider.of<AuthProvider>(context, listen: false)
                                          .partnerForgotPassword(
                                              businessIdController.text.trim());
                                      if (!context.mounted) return;
                                      _showSnackBar(
                                        'Password reset link sent to registered email',
                                        Colors.green,
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      _showSnackBar(e.toString(), Colors.red);
                                    }
                                    businessIdController.dispose();
                                    businessIdFocusNode.dispose();
                                  },
                                  borderRadius: BorderRadius.circular(8 * responsiveScale),
                                  child: Center(
                                    child: Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 16 * responsiveScale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 30 * responsiveScale),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      businessIdController.dispose();
      businessIdFocusNode.dispose();
      isBusinessIdFocusedNotifier.dispose();
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

