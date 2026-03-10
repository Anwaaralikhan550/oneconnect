import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_image.dart';
import '../widgets/sticky_footer.dart';
import '../utils/profile_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dateController = TextEditingController();
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();

  String selectedCountry = 'Select Country';
  File? _profileImage;
  String? _networkProfilePhotoUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        final dob = auth.user!.dateOfBirth;
        final dobText = dob != null
            ? '${dob.month.toString().padLeft(2, '0')}/${dob.day.toString().padLeft(2, '0')}/${dob.year}'
            : '';
        setState(() {
          _usernameController.text = auth.user!.name;
          _fullNameController.text = auth.user!.name;
          _emailController.text = auth.user!.email;
          if (auth.user!.phone != null && auth.user!.phone!.isNotEmpty) {
            _phoneController.text = auth.user!.phone!;
          }
          _genderController.text = auth.user!.gender ?? '';
          _dateController.text = dobText;
          _occupationController.text = auth.user!.occupation ?? '';
          _addressController.text = auth.user!.address ?? '';
          if ((auth.user!.country ?? '').trim().isNotEmpty) {
            selectedCountry = auth.user!.country!.trim();
          }
          _networkProfilePhotoUrl = auth.user!.profilePhotoUrl;
        });
      }
    });
  }

  Future<void> _updateProfileImage() async {
    final File? image = await ProfileImagePicker.showImageSourceDialog(context);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      setState(() {
        _dateController.text = '$mm/$dd/$yyyy';
      });
    }
  }

  Future<void> _applyProfileChanges() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userName = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final name = userName.isNotEmpty ? userName : fullName;
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final gender = _genderController.text.trim();
    final occupation = _occupationController.text.trim();
    final address = _addressController.text.trim();
    final country = selectedCountry == 'Select Country' ? '' : selectedCountry.trim();

    String? dateOfBirthIso;
    final dateRaw = _dateController.text.trim();
    if (dateRaw.isNotEmpty) {
      final parts = dateRaw.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[0]);
        final day = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (month != null && day != null && year != null) {
          final dob = DateTime(year, month, day);
          dateOfBirthIso = dob.toIso8601String();
        }
      }
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name is required')),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }

    String? uploadedPhotoUrl;
    if (_profileImage != null) {
      uploadedPhotoUrl = await auth.uploadProfilePhoto(_profileImage!.path);
      if (uploadedPhotoUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Profile photo upload failed')),
        );
        return;
      }
    }

    final success = await auth.updateProfile(
      name: name,
      email: email,
      phone: phone.isEmpty ? null : phone,
      profilePhotoUrl: uploadedPhotoUrl,
      gender: gender.isEmpty ? null : gender,
      occupation: occupation.isEmpty ? null : occupation,
      address: address.isEmpty ? null : address,
      country: country.isEmpty ? null : country,
      dateOfBirth: dateOfBirthIso,
    );

    if (!mounted) return;

    if (success) {
      if (uploadedPhotoUrl != null) {
        setState(() {
          _networkProfilePhotoUrl = uploadedPhotoUrl;
          _profileImage = null;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildProfilePicture(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAccountDetailsSection(),
                  const SizedBox(height: 15),
                  _buildPersonalDetailsSection(),
                  const SizedBox(height: 15),
                  _buildResidentialDetailsSection(),
                  const SizedBox(height: 20),
                  _buildApplyButton(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StickyFooter(selectedIndex: 4), // Profile is index 4
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 118,
      padding: const EdgeInsets.only(top: 45, bottom: 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          // Back button
          Positioned(
            left: 23,
            top: 21,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Color(0xFF3195AB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.string(
                    '''<svg width="19.76" height="19.76" viewBox="0 0 19.76 19.76" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12.32 15.88L6.44 9.88L12.32 3.88" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>''',
                    width: 19.76,
                    height: 19.76,
                  ),
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            left: 126,
            top: 27,
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 25,
                height: 1.21,
                color: Color(0xFF515151),
              ),
            ),
          ),
          // Notification icon
          Positioned(
            right: 23,
            top: 28,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notification');
              },
              child: SvgPicture.asset(
                'assets/images/notification_icon.svg',
                width: 21,
                height: 20.79,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Transform.translate(
      offset: const Offset(0, -17),
      child: GestureDetector(
        onTap: _updateProfileImage,
        child: Stack(
          children: [
            Container(
              width: 68.55,
              height: 68.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF044870), width: 2),
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                        width: 68.55,
                        height: 68.55,
                      )
                    : buildProfileImage(
                        _networkProfilePhotoUrl,
                        fallbackIcon: Icons.person,
                        iconSize: 35,
                      ),
              ),
            ),
            Positioned(
              right: 2.84,
              bottom: 2.84,
              child: Container(
                width: 19.59,
                height: 19.59,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D7290),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF044870), width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 13, right: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0x4DF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237B98).withOpacity( 0.05),
            offset: const Offset(0, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.21,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: [
              _buildInputField(
                label: 'User Name',
                controller: _usernameController,
                placeholder: 'Enter your User name',
                icon: Icons.person_outline,
                hasBottomMessage: true,
                bottomMessage: 'Use only alphabets',
              ),
              const SizedBox(height: 25),
              _buildInputField(
                label: 'Full Name',
                controller: _fullNameController,
                placeholder: 'Enter your full name',
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 25),
              _buildInputField(
                label: 'Phone Number',
                controller: _phoneController,
                placeholder: 'Enter your phone number',
                icon: Icons.phone_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0x4DF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237B98).withOpacity( 0.05),
            offset: const Offset(0, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.21,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildInputField(
                  label: 'Gender',
                  controller: _genderController,
                  placeholder: 'Enter your Gender',
                  icon: Icons.male,
                  hasBottomMessage: true,
                  bottomMessage: 'Use only alphabets',
                ),
                const SizedBox(height: 10),
                _buildDateField(),
                const SizedBox(height: 8),
                _buildInputField(
                  label: 'Email Address',
                  controller: _emailController,
                  placeholder: 'Enter your email address',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Occupation',
                  controller: _occupationController,
                  placeholder: 'Choose your occupation',
                  icon: Icons.search,
                  hasBottomMessage: true,
                  bottomMessage: 'Choose the most appropriate',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentialDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0x4DF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF237B98).withOpacity( 0.05),
            offset: const Offset(0, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Residential Details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.21,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildAddressField(),
                const SizedBox(height: 8),
                _buildCountryField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool hasBottomMessage = false,
    String bottomMessage = '',
  }) {
    final lowerLabel = label.toLowerCase();
    final resolvedKeyboardType = lowerLabel.contains('phone')
        ? TextInputType.phone
        : lowerLabel.contains('email')
            ? TextInputType.emailAddress
            : TextInputType.text;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.1,
                color: Color(0xFF19213D),
              ),
            ),
          ),
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5CBDE), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19213D).withOpacity( 0.11),
                  offset: const Offset(0, 0.5),
                  blurRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF9AA0B6),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: resolvedKeyboardType,
                    enableInteractiveSelection: false,
                    contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.1,
                        color: Color(0xFF9AA0B6),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 21),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasBottomMessage)
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFF6D758F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    bottomMessage,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.25,
                      color: Color(0xFF6D758F),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: const Text(
              'Date',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.1,
                color: Color(0xFF19213D),
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2388FF), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2388FF).withOpacity( 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 7,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
                      child: Text(
                        _dateController.text.isEmpty ? 'MM/DD/YYYY' : _dateController.text,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.1,
                          color: _dateController.text.isEmpty ? const Color(0xFF9AA0B6) : const Color(0xFF19213D),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Color(0xFF19213D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: const Text(
              'Address',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.1,
                color: Color(0xFF19213D),
              ),
            ),
          ),
          Container(
            height: 123,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5CBDE), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19213D).withOpacity( 0.11),
                  offset: const Offset(0, 0.5),
                  blurRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF9AA0B6),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                    child: TextFormField(
                      controller: _addressController,
                      maxLines: 4,
                      enableInteractiveSelection: false,
                      contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                      decoration: const InputDecoration(
                        hintText: 'Write your complete address here...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.1,
                          color: Color(0xFF9AA0B6),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFF6D758F),
                ),
                SizedBox(width: 4),
                Text(
                  '12/240',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.25,
                    color: Color(0xFF6D758F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryField() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: const Text(
              'Country',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.1,
                color: Color(0xFF19213D),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                onSelect: (Country country) {
                  setState(() {
                    selectedCountry = country.name;
                  });
                },
              );
            },
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5CBDE), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF19213D).withOpacity( 0.11),
                    offset: const Offset(0, 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF249F58),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      selectedCountry,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.1,
                        color: Color(0xFF9AA0B6),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF9AA0B6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: auth.isLoading ? null : _applyProfileChanges,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Button.svg',
                    width: double.infinity,
                    height: 52,
                    fit: BoxFit.fill,
                  ),
                  if (auth.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _genderController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

