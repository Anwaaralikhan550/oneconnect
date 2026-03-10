import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class JoinCommunitySignupScreen extends StatefulWidget {
  const JoinCommunitySignupScreen({super.key});

  @override
  State<JoinCommunitySignupScreen> createState() => _JoinCommunitySignupScreenState();
}

class _JoinCommunitySignupScreenState extends State<JoinCommunitySignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isFullNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _showFullNameError = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(() {
      setState(() {
        _isFullNameFocused = _fullNameFocusNode.hasFocus;
      });
    });
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    bool hasError = false;
    
    if (_fullNameController.text.isEmpty) {
      setState(() {
        _showFullNameError = true;
      });
      hasError = true;
    } else {
      setState(() {
        _showFullNameError = false;
      });
    }

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

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to Terms & Conditions', Colors.red);
      hasError = true;
    }

    if (hasError) {
      return;
    }

    try {
      final success = await Provider.of<AuthProvider>(context, listen: false).register(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted && success) {
        _showSnackBar('Signup successful!', Colors.green);
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Colors.red);
      }
    }
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
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        top: 40 * responsiveScale,
                        left: 20 * responsiveScale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40 * responsiveScale,
                            height: 40 * responsiveScale,
                            decoration: BoxDecoration(
                              color: Color(0xFF0097B2).withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: 20 * responsiveScale,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20 * responsiveScale),
                
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30 * responsiveScale),
                  child: Text(
                    'Join the community',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 30 * responsiveScale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 20 * responsiveScale),
                
                // Full Name Input
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
                  child: _buildFullNameField(responsiveScale),
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
                
                // Terms & Conditions Checkbox
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
                  child: Row(
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
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            borderRadius: BorderRadius.circular(6 * responsiveScale),
                            child: _agreeToTerms
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
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14 * responsiveScale,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF010101),
                            ),
                            children: [
                              TextSpan(text: 'Agree with '),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/terms-and-conditions');
                                  },
                                  child: Text(
                                    'Terms & Condition',
                                    style: TextStyle(
                                      color: Color(0xFF237B98),
                                      decoration: TextDecoration.underline,
                                    ),
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
                
                SizedBox(height: 25 * responsiveScale),
                
                // Signup Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33 * responsiveScale),
                  child: Container(
                    width: screenWidth * 0.85 < 324 ? screenWidth * 0.85 : 324 * responsiveScale,
                    height: 48 * responsiveScale,
                    decoration: BoxDecoration(
                      color: Color(0xFF0097B2),
                      borderRadius: BorderRadius.circular(8 * responsiveScale),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleSignup,
                        borderRadius: BorderRadius.circular(8 * responsiveScale),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Signup',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16 * responsiveScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8 * responsiveScale),
                              Icon(
                                Icons.arrow_forward,
                                size: 20 * responsiveScale,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 20 * responsiveScale),
                
                // Login Link
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25 * responsiveScale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14 * responsiveScale,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF010101),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Log In',
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

  Widget _buildFullNameField(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10 * scale),
          child: Text(
            'Full Name',
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
              color: _showFullNameError 
                  ? Colors.red 
                  : (_isFullNameFocused 
                      ? Color(0xFF6D758F) 
                      : (_fullNameController.text.isNotEmpty 
                          ? Color(0xFF6D758F) 
                          : Color(0xFFC5CBDE))),
              width: _showFullNameError ? 1 : (_isFullNameFocused ? 1 : 0.5),
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
                // Error icon (red circle with white X) or User icon
                _showFullNameError && _fullNameController.text.isEmpty
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
                        Icons.person_outline,
                        size: 20 * scale,
                        color: _fullNameController.text.isNotEmpty 
                            ? Color(0xFF19213D) 
                            : Color(0xFF6D758F),
                      ),
                SizedBox(width: 10 * scale),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: _fullNameController,
                    focusNode: _fullNameFocusNode,
                    keyboardType: TextInputType.name,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
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
                        if (_showFullNameError && value.isNotEmpty) {
                          _showFullNameError = false;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Help text
        SizedBox(height: 4 * scale),
        Text(
          'Use only alphabets.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6D758F),
          ),
        ),
      ],
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
                // Error icon (red circle with white X) or Email icon
                _showEmailError && _emailController.text.isEmpty
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
                        Icons.email_outlined,
                        size: 20 * scale,
                        color: _emailController.text.isNotEmpty 
                            ? Color(0xFF19213D) 
                            : Color(0xFF6D758F),
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
                    : Icon(
                        Icons.lock_outline,
                        size: 20 * scale,
                        color: Color(0xFF9AA0B6),
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
                
                // Eye icon - toggle visibility on tap
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20 * scale,
                    color: Color(0xFF9AA0B6),
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}


