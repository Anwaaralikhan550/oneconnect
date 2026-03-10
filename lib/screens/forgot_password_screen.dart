import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email address', Colors.red);
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .forgotPassword(_emailController.text.trim());
      if (mounted) {
        _showSnackBar('Password reset link sent to your email', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
            children: [
              SizedBox(height: 25),
              
              // Back button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF3F9),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 20,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 35),
              
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF160D1F),
                    height: 1.14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 35),
              
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Enter your email for the verification process, \nwe will send a reset link to your email',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2C),
                    height: 1.21,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 35),
              
              // Email Input Field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: _buildEmailField(),
              ),
              
              SizedBox(height: 20),
              
              // Continue Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 33),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF3499AF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleContinue,
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 41),
            ],
          ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Email',
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
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isEmailFocused 
                  ? Color(0xFF2388FF) 
                  : (_emailController.text.isNotEmpty 
                      ? Color(0xFF6D758F) 
                      : Color(0xFFC5CBDE)),
              width: _isEmailFocused ? 1 : 0.5,
            ),
            boxShadow: _isEmailFocused
                ? [
                    BoxShadow(
                      color: Color(0xFF2388FF).withOpacity( 0.15),
                      blurRadius: 7,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Color(0xFF19213D).withOpacity( 0.11),
                      blurRadius: 2,
                      offset: Offset(0, 0.5),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Email icon
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: _emailController.text.isNotEmpty 
                      ? Color(0xFF19213D) 
                      : Color(0xFF19213D),
                ),
                SizedBox(width: 10),
                
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
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF19213D),
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
                
                // Search icon (as shown in Figma)
                if (_isEmailFocused)
                  Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xFF19213D),
                  ),
              ],
            ),
          ),
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

