import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:country_picker/country_picker.dart';

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final IconData? icon;
  final double scale;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isFilled;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.icon,
    required this.scale,
    required this.focusNode,
    this.validator,
    this.keyboardType,
    this.isFilled = false,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.21,
            ),
          ),
          SizedBox(height: 8 * scale),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          enableInteractiveSelection: false,
          contextMenuBuilder: (context, state) => const SizedBox.shrink(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16 * scale,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16 * scale,
              color: Colors.grey.shade500,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF3499AF),
                    size: 20 * scale,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? (isFilled ? const Color(0xFFF8F9FA) : Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : focusNode.hasFocus
                        ? Colors.green
                        : const Color(0xFFE0E0E0),
                width: errorText != null
                    ? 2.5
                    : focusNode.hasFocus
                        ? 2.5
                        : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : const Color(0xFFE0E0E0),
                width: errorText != null ? 2.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.green,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.5,
              ),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 12 * scale,
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4 * scale),
          Padding(
            padding: EdgeInsets.only(left: 4 * scale),
            child: Text(
              errorText!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12 * scale,
                color: Colors.red,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PartnerStep2Screen extends StatefulWidget {
  const PartnerStep2Screen({super.key});

  @override
  State<PartnerStep2Screen> createState() => _PartnerStep2ScreenState();
}

class _PartnerStep2ScreenState extends State<PartnerStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPhoneFocused = false;

  // Selected country for phone field
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

  // Selected business type
  String? _selectedBusinessType;

  // Focus nodes for tracking focus state
  final _businessNameFocus = FocusNode();
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _dropdownFocus = FocusNode();

  // Error messages for each field
  final Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    // Live validation while typing
    _businessNameController.addListener(() {
      _updateFieldError('businessName', _validateBusinessName(_businessNameController.text));
    });
    _fullNameController.addListener(() {
      _updateFieldError('fullName', _validateFullName(_fullNameController.text));
    });
    _emailController.addListener(() {
      _updateFieldError('email', _validateEmail(_emailController.text));
    });
    _passwordController.addListener(() {
      _updateFieldError('password', _validatePassword(_passwordController.text));
    });
    _phoneController.addListener(() {
      _updateFieldError('phone', _validatePhone(_phoneController.text));
    });
    _phoneFocus.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocus.hasFocus;
      });
    });
  }

  void _updateFieldError(String key, String? error) {
    if (_fieldErrors[key] == error) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _fieldErrors[key] == error) return;
        setState(() {
          _fieldErrors[key] = error;
        });
      });
      return;
    }
    setState(() {
      _fieldErrors[key] = error;
    });
  }

  String? _validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your business name';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your email address';
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please enter your password';
    if (v.length < 10) return 'Password must be at least 10 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Password must include an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Password must include a lowercase letter';
    if (!RegExp(r'\d').hasMatch(v)) return 'Password must include a number';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) return 'Password must include a special character';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _businessNameFocus.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _dropdownFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive calculations
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24 * scale),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25 * scale),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30 * scale),

                  // Title
                  SizedBox(
                    width: 326 * scale,
                    child: Text(
                      'Ready to boost your presence in the community?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.21,
                      ),
                    ),
                  ),

                  SizedBox(height: 30 * scale),

                  // Business Name field
                  _buildInputField(
                    controller: _businessNameController,
                    label: 'Business Name',
                    placeholder: 'Enter your business name',
                    icon: Icons.business,
                    scale: scale,
                    focusNode: _businessNameFocus,
                    fieldKey: 'businessName',
                    validator: _validateBusinessName,
                  ),

                  SizedBox(height: 25 * scale),

                  // Password field
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    scale: scale,
                    focusNode: _passwordFocus,
                    fieldKey: 'password',
                    validator: _validatePassword,
                  ),

                  SizedBox(height: 25 * scale),

                  // Full Name field (filled state)
                  _buildInputField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    placeholder: 'Complete name as per CNIC',
                    icon: Icons.person_outline,
                    scale: scale,
                    focusNode: _fullNameFocus,
                    fieldKey: 'fullName',
                    isFilled: true,
                    validator: _validateFullName,
                  ),

                  SizedBox(height: 25 * scale),

                  // Email field
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    placeholder: 'Business Email',
                    icon: Icons.email_outlined,
                    scale: scale,
                    focusNode: _emailFocus,
                    fieldKey: 'email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  SizedBox(height: 25 * scale),

                  // Business Type dropdown
                  _buildDropdownField(
                    label: 'Business Type',
                    scale: scale,
                    focusNode: _dropdownFocus,
                  ),

                  SizedBox(height: 25 * scale),

                  // Phone number field (filled state)
                  _buildPhoneField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    scale: scale,
                    focusNode: _phoneFocus,
                    fieldKey: 'phone',
                    validator: _validatePhone,
                  ),

                  SizedBox(height: 25 * scale),

                  // Terms and conditions checkbox
                  _buildCheckboxField(scale: scale),

                  SizedBox(height: 25 * scale),

                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48 * scale,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(8 * scale),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15 * scale),
                      Expanded(
                        child: Container(
                          height: 48 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3499AF),
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  // Map display names to backend BusinessType enum values
                                  const typeMap = {
                                    'Services': 'SERVICE_PROVIDER',
                                    'Business': 'RETAIL_STORE',
                                    'Amenities': 'OTHER',
                                  };
                                  Navigator.pushNamed(
                                    context,
                                    '/partner-step3',
                                    arguments: {
                                      'businessName': _businessNameController.text.trim(),
                                      'password': _passwordController.text,
                                      'ownerFullName': _fullNameController.text.trim(),
                                      'businessEmail': _emailController.text.trim(),
                                      'businessType': typeMap[_selectedBusinessType] ?? 'OTHER',
                                      'phone': _phoneController.text.trim(),
                                      'countryCode': '+${_selectedCountry.phoneCode}',
                                    },
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8 * scale),
                              child: Center(
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15 * scale),

                  // Login link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/partner-login');
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.21,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required double scale,
    required FocusNode focusNode,
    required String fieldKey,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isFilled = false,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild to update border color
        if (!hasFocus && validator != null) {
          final error = validator(controller.text);
          _updateFieldError(fieldKey, error);
        }
      },
      child: CustomTextField(
        controller: controller,
        label: label,
        placeholder: placeholder,
        icon: icon,
        scale: scale,
        focusNode: focusNode,
        validator: (value) {
          final error = validator?.call(value);
          _updateFieldError(fieldKey, error);
          return error;
        },
        keyboardType: keyboardType,
        isFilled: isFilled,
        errorText: _fieldErrors[fieldKey],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double scale,
    required FocusNode focusNode,
    required String fieldKey,
    String? Function(String?)? validator,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild to update border color
        if (!hasFocus && validator != null) {
          final error = validator(controller.text);
          _updateFieldError(fieldKey, error);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller,
            label: label,
            placeholder: 'Your Password',
            icon: icon,
            scale: scale,
            focusNode: focusNode,
            validator: (value) {
              final error = validator?.call(value);
              _updateFieldError(fieldKey, error);
              return error;
            },
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
                size: 20 * scale,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            errorText: _fieldErrors[fieldKey],
          ),
          SizedBox(height: 4 * scale),
          Padding(
            padding: EdgeInsets.only(left: 4 * scale),
            child: Text(
              'Use 10+ chars with uppercase, lowercase, number, and special character.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12 * scale,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required double scale,
    required FocusNode focusNode,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild to update border color
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.21,
            ),
          ),
          SizedBox(height: 8 * scale),
          DropdownButtonFormField<String>(
            focusNode: focusNode,
            value: _selectedBusinessType,
            decoration: InputDecoration(
              hintText: 'Select business type',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16 * scale,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                Icons.business_center,
                color: const Color(0xFF3499AF),
                size: 20 * scale,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
                borderSide: BorderSide(
                  color: focusNode.hasFocus ? Colors.green : const Color(0xFFE0E0E0),
                  width: focusNode.hasFocus ? 2.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
                borderSide: const BorderSide(
                  color: Colors.green,
                  width: 2.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 12 * scale,
              ),
            ),
            items: [
              'Services',
              'Business',
              'Amenities',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16 * scale,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBusinessType = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a business type';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    required double scale,
    required FocusNode focusNode,
    required String fieldKey,
    String? Function(String?)? validator,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild to update border color
        if (!hasFocus && validator != null) {
          final error = validator(controller.text);
          _updateFieldError(fieldKey, error);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.21,
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(
                color: _fieldErrors[fieldKey] != null
                    ? Colors.red
                    : _isPhoneFocused
                        ? Colors.green
                        : const Color(0xFFE0E0E0),
                width: _fieldErrors[fieldKey] != null
                    ? 2.5
                    : _isPhoneFocused
                        ? 2.5
                        : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
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
                                color: const Color(0xFF8C98A8).withOpacity(0.2),
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
                          style: TextStyle(fontSize: 24 * scale),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          _selectedCountry.countryCode,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF19213D),
                          ),
                        ),
                        SizedBox(width: 4 * scale),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20 * scale,
                          color: const Color(0xFF19213D),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  // Divider
                  Container(
                    width: 1,
                    height: 30 * scale,
                    color: const Color(0xFFE0E0E0),
                  ),
                  SizedBox(width: 16 * scale),
                  // Phone input
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final error = validator?.call(value);
                        _updateFieldError(fieldKey, error);
                        return error;
                      },
                      enableInteractiveSelection: false,
                      contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16 * scale,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: '+${_selectedCountry.phoneCode} (000) 000-0000',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF19213D).withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_fieldErrors[fieldKey] != null) ...[
            SizedBox(height: 4 * scale),
            Padding(
              padding: EdgeInsets.only(left: 4 * scale),
              child: Text(
                _fieldErrors[fieldKey]!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12 * scale,
                  color: Colors.red,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxField({required double scale}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20 * scale,
          height: 20 * scale,
          margin: EdgeInsets.only(top: 2 * scale, right: 8 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF3499AF),
            borderRadius: BorderRadius.circular(4 * scale),
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 14 * scale,
          ),
        ),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14 * scale,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
