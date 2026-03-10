import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) return;

    bool hasError = false;

    if (_emailController.text.isEmpty) {
      setState(() {
        _showEmailError = true;
      });
      hasError = true;
    } else {
      setState(() {
        _showEmailError = false;
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
      _showSnackBar('Please enter email and password', Colors.red);
      return;
    }
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      await TokenStorage.setRememberMe(_rememberMe);
      if (!mounted) return;
      _showSnackBar('Login successful!', Colors.green);
      Navigator.pushNamedAndRemoveUntil(context, '/main-screen-of-oneconnect', (route) => false);
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

    final TextEditingController emailController = TextEditingController();
    final FocusNode emailFocusNode = FocusNode();
    final ValueNotifier<bool> isEmailFocusedNotifier = ValueNotifier<bool>(false);

    emailFocusNode.addListener(() {
      isEmailFocusedNotifier.value = emailFocusNode.hasFocus;
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
              valueListenable: isEmailFocusedNotifier,
              builder: (context, isEmailFocused, child) {
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
                            emailController.dispose();
                            emailFocusNode.dispose();
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
                          'Enter your email for the verification process, we will send code to your email',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15 * responsiveScale,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C),
                            height: 1.21,
                          ),
                        ),
                        
                        SizedBox(height: 30 * responsiveScale),
                        
                        // Email Label
                        Text(
                          'Email',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16 * responsiveScale,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF19213D),
                          ),
                        ),
                        
                        SizedBox(height: 10 * responsiveScale),
                        
                        // Email Input Field
                        Container(
                          height: 62 * responsiveScale,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16 * responsiveScale),
                            border: Border.all(
                              color: isEmailFocused 
                                  ? Color(0xFF2388FF) 
                                  : (emailController.text.isNotEmpty 
                                      ? Color(0xFF6D758F) 
                                      : Color(0xFFC5CBDE)),
                              width: isEmailFocused ? 1 : 0.5,
                            ),
                            boxShadow: isEmailFocused
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
                                // Email icon
                                Icon(
                                  Icons.email_outlined,
                                  size: 20 * responsiveScale,
                                  color: Color(0xFF19213D),
                                ),
                                SizedBox(width: 10 * responsiveScale),
                                
                                // Text field
                                Expanded(
                                  child: TextField(
                                    controller: emailController,
                                    focusNode: emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    enableInteractiveSelection: false,
                                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email address',
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
                                if (emailController.text.isEmpty) {
                                  _showSnackBar('Please enter your email address', Colors.red);
                                  return;
                                }
                                try {
                                  await Provider.of<AuthProvider>(context, listen: false)
                                      .forgotPassword(emailController.text.trim());
                                  if (context.mounted) {
                                    _showSnackBar('Password reset link sent to your email', Colors.green);
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showSnackBar(e.toString(), Colors.red);
                                  }
                                }
                                emailController.dispose();
                                emailFocusNode.dispose();
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
      emailController.dispose();
      emailFocusNode.dispose();
      isEmailFocusedNotifier.dispose();
    });
  }

  void _handleGoogleLogin() {
    _showSnackBar('This option is currently disabled', Colors.orange);
  }

  void _handleAppleLogin() {
    _showSnackBar('This option is currently disabled', Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive scaling based on design width (390px is common mobile design)
    final designWidth = 390.0;
    final scale = screenWidth / designWidth;
    
    // Clamp scale between 0.8 and 1.2 for very small/large screens
    final responsiveScale = scale.clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
            // Header with background image and logo
            Container(
              height: 184 * responsiveScale,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Header123.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60 * responsiveScale),
                  bottomRight: Radius.circular(60 * responsiveScale),
                ),
              ),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Title and subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30 * responsiveScale),
              child: Column(
                children: [
                  Text(
                    'Login Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 30 * responsiveScale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * responsiveScale),
                  Text(
                    'Please login with your registered account',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16 * responsiveScale,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity( 0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Email Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
              child: _buildEmailField(responsiveScale),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Password Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
              child: _buildPasswordField(responsiveScale),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Remember me and Forgot password
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
              child: Row(
                children: [
                  // Remember me checkbox
                  Row(
                    children: [
                      Container(
                        width: 20 * responsiveScale,
                        height: 20 * responsiveScale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6 * responsiveScale),
                          border: Border.all(
                            color: Color(0xFF667085),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            borderRadius: BorderRadius.circular(6 * responsiveScale),
                            child: _rememberMe
                                ? Icon(
                                    Icons.check,
                                    size: 14 * responsiveScale,
                                    color: Color(0xFF237B98),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * responsiveScale),
                      Text(
                        'Remember Me',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14 * responsiveScale,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF010101),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Forgot password
                  InkWell(
                    onTap: _handleForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14 * responsiveScale,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF237B98),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25 * responsiveScale),
            
            // Login Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 33 * responsiveScale),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    width: screenWidth * 0.85 < 324 ? screenWidth * 0.85 : 324 * responsiveScale,
                    height: 48 * responsiveScale,
                    decoration: BoxDecoration(
                      color: authProvider.isLoading ? const Color(0xFF8CC8D4) : const Color(0xFF3499AF),
                      borderRadius: BorderRadius.circular(8 * responsiveScale),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authProvider.isLoading ? null : _handleLogin,
                        borderRadius: BorderRadius.circular(8 * responsiveScale),
                        child: Center(
                          child: authProvider.isLoading
                              ? SizedBox(
                                  width: 20 * responsiveScale,
                                  height: 20 * responsiveScale,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Sign in',
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
                  );
                },
              ),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Or divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32 * responsiveScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                  SizedBox(width: 22 * responsiveScale),
                  Text(
                    'or continue with',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16 * responsiveScale,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF545454),
                    ),
                  ),
                  SizedBox(width: 22 * responsiveScale),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Social login buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * responsiveScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Login Button
                  _buildSocialButton(
                    onTap: _handleGoogleLogin,
                    responsiveScale: responsiveScale,
                    child: SvgPicture.asset(
                      'assets/images/devicon_google.svg',
                      width: 25 * responsiveScale,
                      height: 25 * responsiveScale,
                    ),
                  ),
                  SizedBox(width: 40 * responsiveScale),
                  // Apple Login Button
                  _buildSocialButton(
                    onTap: _handleAppleLogin,
                    responsiveScale: responsiveScale,
                    child: SvgPicture.asset(
                      'assets/images/apple_icon.svg',
                      width: 29 * responsiveScale,
                      height: 29 * responsiveScale,
                      colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20 * responsiveScale),
            
            // Signup Link
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14 * responsiveScale,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF010101),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/join-community-signup');
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14 * responsiveScale,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF237B98),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30 * responsiveScale),
          ],
        ),
      ),
    ),
  ),
    );
  }

  Widget _buildEmailField(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10 * scale),
          child: Text(
            'Email',
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
              color: _showEmailError 
                  ? Colors.red 
                  : (_isEmailFocused 
                      ? Color(0xFF6D758F) 
                      : (_emailController.text.isNotEmpty 
                          ? Color(0xFF6D758F) 
                          : Color(0xFFC5CBDE))),
              width: _showEmailError ? 1 : (_isEmailFocused ? 1 : 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF19213D).withOpacity( 0.11),
                blurRadius: 2 * scale,
                offset: Offset(0, 0.5 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            child: Row(
              children: [
                // Error icon (red circle with white X) or User icon
                _showEmailError && _emailController.text.isEmpty
                    ? Container(
                        width: 20 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red,width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14 * scale,
                          color: Colors.red,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/images/User12.svg',
                        width: 20 * scale,
                        height: 20 * scale,
                        colorFilter: ColorFilter.mode(
                          _emailController.text.isNotEmpty 
                              ? Color(0xFF19213D) 
                              : Color(0xFF6D758F),
                          BlendMode.srcIn,
                        ),
                      ),
                SizedBox(width: 10 * scale),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
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
                        if (_showEmailError && value.isNotEmpty) {
                          _showEmailError = false;
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
                color: Color(0xFF19213D).withOpacity( 0.11),
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
                          border: Border.all(color: Colors.red,width: 1.5),
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

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget child,
    required double responsiveScale,
  }) {
    return Container(
      width: 54 * responsiveScale,
      height: 50 * responsiveScale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * responsiveScale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.25),
            blurRadius: 4 * responsiveScale,
            offset: const Offset(0, 4),
            spreadRadius: 2 * responsiveScale,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * responsiveScale),
          child: Center(child: child),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

