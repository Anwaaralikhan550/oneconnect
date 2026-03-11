import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EmailPasswordSignupScreen extends StatefulWidget {
  const EmailPasswordSignupScreen({super.key});

  @override
  State<EmailPasswordSignupScreen> createState() => _EmailPasswordSignupScreenState();
}

class _EmailPasswordSignupScreenState extends State<EmailPasswordSignupScreen> {
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
  String? _phoneFromPreviousStep;
  bool _argsLoaded = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _submitError;
  bool _fullNameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _strongPasswordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{10,128}$');

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
    _fullNameController.addListener(_handleFullNameChanged);
    _emailController.addListener(_handleEmailChanged);
    _passwordController.addListener(_handlePasswordChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final rawPhone = (args['phone'] ?? '').toString().trim();
      if (rawPhone.isNotEmpty) {
        _phoneFromPreviousStep = rawPhone;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_handleFullNameChanged);
    _emailController.removeListener(_handleEmailChanged);
    _passwordController.removeListener(_handlePasswordChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleFullNameChanged() {
    if (!mounted) return;
    setState(() {
      _fullNameTouched = true;
      _fullNameError = _validateFullName(_fullNameController.text);
      _submitError = null;
    });
  }

  void _handleEmailChanged() {
    if (!mounted) return;
    setState(() {
      _emailTouched = true;
      _emailError = _validateEmail(_emailController.text);
      _submitError = null;
    });
  }

  void _handlePasswordChanged() {
    if (!mounted) return;
    setState(() {
      _passwordTouched = true;
      _passwordError = _validatePassword(_passwordController.text);
      _submitError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with background image, gradient overlay, and back button
            Container(
              height: 238,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Header2.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(75),
                  bottomRight: Radius.circular(75),
                ),
              ),
              child: Column(
                children: [
                  // Top section with back button
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 9, right: 25),
                    child: Row(
                      children: [
                        // Back button
                        Material(
                          color: Color(0xFF02A6C3),
                          shape: CircleBorder(),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            customBorder: CircleBorder(),
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Join the community title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Join the community',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Full Name Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: _buildInputField(
                controller: _fullNameController,
                focusNode: _fullNameFocusNode,
                isFocused: _isFullNameFocused,
                label: 'Full Name',
                placeholder: 'Enter your full name',
                icon: Icons.person_outline,
                errorText: _fullNameTouched ? _fullNameError : null,
                helpText: 'Use only alphabets',
              ),
            ),
            
            SizedBox(height: 20),
            
            // Email Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: _buildInputField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                isFocused: _isEmailFocused,
                label: 'Email',
                placeholder: 'Enter your email address',
                icon: Icons.email_outlined,
                errorText: _emailTouched ? _emailError : null,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Password Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: _buildPasswordField(),
            ),
            
            SizedBox(height: 20),
            
            // Terms and conditions checkbox
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Color(0xFF707070),
                        width: 2,
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
                        borderRadius: BorderRadius.circular(6),
                        child: _agreeToTerms
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Color(0xFF237B98),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Agree with',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF393939),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/terms-and-conditions');
                    },
                    child: Text(
                      'Terms & Condition',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF237B98),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25),
            
            // Signup Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0097B2),
                      Color(0xFF008EA8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Color(0xFF008EA8),
                    width: 4,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _agreeToTerms ? () {
                      _handleSignup();
                    } : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Signup',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
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

            if (_submitError != null) ...[
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE57373)),
                  ),
                  child: Text(
                    _submitError!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB3261E),
                    ),
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF237B98),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String placeholder,
    required IconData icon,
    String? errorText,
    String? helpText,
    TextInputType? keyboardType,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF19213D),
            ),
          ),
        ),
        
        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE57373)
                  : isFocused
                      ? Color(0xFF6D758F)
                      : (controller.text.isNotEmpty
                          ? Color(0xFF6D758F)
                          : Color(0xFFC5CBDE)),
              width: isFocused ? 1 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF19213D).withOpacity( 0.11),
                blurRadius: 2,
                offset: Offset(0, 0.5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  size: 20,
                  color: controller.text.isNotEmpty 
                      ? Color(0xFF19213D) 
                      : Color(0xFF6D758F),
                ),
                SizedBox(width: 10),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6D758F),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF19213D),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        if (hasError) ...[
          SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB3261E),
            ),
          ),
        ],

        if (helpText != null && !hasError) ...[
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFF6D758F),
              ),
              SizedBox(width: 4),
              Text(
                helpText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D758F),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    final visiblePasswordError = _passwordTouched ? _passwordError : null;
    final hasError = visiblePasswordError != null && visiblePasswordError.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Password',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF19213D),
            ),
          ),
        ),
        
        // Password field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE57373)
                  : _isPasswordFocused
                      ? Color(0xFF6D758F)
                      : Color(0xFFC5CBDE),
              width: _isPasswordFocused ? 1 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF19213D).withOpacity( 0.11),
                blurRadius: 2,
                offset: Offset(0, 0.5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Lock icon
                Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: Color(0xFF9AA0B6),
                ),
                SizedBox(width: 10),
                
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
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6D758F),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF19213D),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                
                // Eye icon
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: Color(0xFF9AA0B6),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (hasError) ...[
          SizedBox(height: 6),
          Text(
            visiblePasswordError!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB3261E),
            ),
          ),
        ] else ...[
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFF6D758F),
              ),
              SizedBox(width: 4),
              Text(
                '10+ chars with uppercase, lowercase, number and symbol',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D758F),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleSignup() async {
    final fullNameError = _validateFullName(_fullNameController.text);
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _fullNameTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
      _fullNameError = fullNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _submitError = null;
    });

    if (fullNameError != null || emailError != null || passwordError != null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneFromPreviousStep,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Account created successfully!', Colors.green);
      Navigator.pushNamedAndRemoveUntil(context, '/main-screen-of-oneconnect', (route) => false);
    } else {
      final err = (authProvider.error ?? '').trim();
      setState(() {
        _submitError = err.isEmpty
            ? 'Signup failed. Please check your details and try again.'
            : err;
        if (_submitError!.toLowerCase().contains('email')) {
          _emailError = _submitError;
        }
        if (_submitError!.toLowerCase().contains('password')) {
          _passwordError = _submitError;
        }
      });
    }
  }

  String? _validateFullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please enter your full name.';
    if (trimmed.length < 2) return 'Full name must be at least 2 characters.';
    return null;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please enter your email address.';
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Please enter your password.';
    if (!_strongPasswordRegex.hasMatch(value)) {
      return 'Password must be 10+ chars with uppercase, lowercase, number and symbol.';
    }
    return null;
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
