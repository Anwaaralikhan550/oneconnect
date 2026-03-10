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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
    String? helpText,
    TextInputType? keyboardType,
  }) {
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
              color: isFocused 
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
        
        // Help text
        if (helpText != null) ...[ 
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
              color: _isPasswordFocused 
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
        
        // Help text
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
              '8+ characters with numbers/symbols',
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
    );
  }

  void _handleSignup() async {
    if (_fullNameController.text.isEmpty) {
      _showSnackBar('Please enter your full name', Colors.red);
      return;
    }

    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email address', Colors.red);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password', Colors.red);
      return;
    }

    if (_passwordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters', Colors.red);
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
      final msg = err.isEmpty
          ? 'Signup failed'
          : (err.toLowerCase().contains('already registered')
              ? 'This email is already registered. Please login instead.'
              : err);
      _showSnackBar(msg, Colors.red);
    }
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
