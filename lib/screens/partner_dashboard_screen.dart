import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/partner_provider.dart';
import '../utils/map_utils.dart';
import '../models/partner_model.dart';
import '../models/business_model.dart';
import '../models/amenity_model.dart';
import '../models/service_provider_model.dart';
import 'dart:io';

class _ServiceVisualOption {
  final String label;
  final String iconAsset;

  const _ServiceVisualOption(this.label, this.iconAsset);
}

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  bool _isBusinessOpen = true;
  final Set<String> _selectedDays = {};
  Country _selectedCountry = Country.parse('PK');
  final TextEditingController _phoneController = TextEditingController();
  bool _followUs = false;
  String? _selectedCategory;
  String? _dashboardCategory;
  String? _profileDashboardCategory;
  static const String _catServices = 'Service';
  static const String _catBusinesses = 'Business';
  static const String _catAmenities = 'Amenity';
  final bool _promotionsEnabled = false;
  bool _profileSynced = false;
  bool _expandBusinessTimings = true;
  bool _expandBusinessAddress = false;
  bool _expandContactInfo = false;
  bool _expandGeneralSettings = false;
  bool _expandMediaUpload = false;
  bool _expandPromotions = false;

  // Social links (partner profile)
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Media Upload state
  final ImagePicker _imagePicker = ImagePicker();
  String? _galleryServiceProviderId;

  // Promotions state
  final TextEditingController _promotionTitleController = TextEditingController();
  final TextEditingController _promotionPriceController = TextEditingController();
  final TextEditingController _promotionDiscountController = TextEditingController();
  final TextEditingController _promotionDescriptionController = TextEditingController();
  File? _promotionImage;
  File? _partnerProfileImage;
  String? _promotionBusinessId;

  // Service Provider form state
  final TextEditingController _spNameController = TextEditingController();
  final TextEditingController _spPhoneController = TextEditingController();
  final TextEditingController _spWhatsappController = TextEditingController();
  final TextEditingController _spAddressController = TextEditingController();
  final TextEditingController _spCityController = TextEditingController(text: 'Lahore');
  final TextEditingController _spChargeController = TextEditingController();
  final TextEditingController _spWorkingSinceController = TextEditingController();
  final TextEditingController _spResponseTimeController = TextEditingController();
  final TextEditingController _spVendorIdController = TextEditingController();
  final TextEditingController _spDoctorIdController = TextEditingController();
  final TextEditingController _spExperienceYearsController = TextEditingController();
  final TextEditingController _spHospitalNameController = TextEditingController();
  final TextEditingController _spConsultationChargeController = TextEditingController();
  final TextEditingController _spPatientsCountController = TextEditingController();
  final TextEditingController _spJobsCompletedController = TextEditingController();
  final TextEditingController _spSkillInputController = TextEditingController();
  final FocusNode _spSkillFocusNode = FocusNode();
  String? _spImageUrl;
  File? _spImageFile;
  String? _spServiceType;
  bool _spFollowEnabled = false;
  bool _spProfessionalProfileEnabled = false;
  String? _editingServiceProviderId;
  List<String> _spSelectedSkills = [];
  List<String> _spSuggestedSkills = [];
  List<Map<String, dynamic>> _serviceCategories = [];

  // Business form state
  final TextEditingController _bizNameController = TextEditingController();
  final TextEditingController _bizLocationController = TextEditingController();
  final TextEditingController _bizPhoneController = TextEditingController();
  final TextEditingController _bizDescController = TextEditingController();
  final TextEditingController _bizOpeningController = TextEditingController();
  final TextEditingController _bizClosingController = TextEditingController();
  final TextEditingController _bizOperatingDaysController = TextEditingController();
  final TextEditingController _bizServicesController = TextEditingController();
  final TextEditingController _bizFacebookController = TextEditingController();
  final TextEditingController _bizInstagramController = TextEditingController();
  final TextEditingController _bizWhatsappController = TextEditingController();
  final TextEditingController _bizWebsiteController = TextEditingController();
  final TextEditingController _bizBedsController = TextEditingController();
  final TextEditingController _bizBathsController = TextEditingController();
  final TextEditingController _bizKitchenController = TextEditingController();
  final TextEditingController _bizPriceController = TextEditingController();
  final TextEditingController _bizSqftController = TextEditingController();
  String? _bizImageUrl;
  File? _bizImageFile;
  String? _bizCategory;
  bool _bizFollowEnabled = true;
  String? _bizPropertyType;
  String? _bizPropertyPurpose;
  String? _bizPropertyStatus;
  String? _bizRealEstateAgentId;
  String? _editingBusinessId;

  // Amenity form state
  final TextEditingController _amenityNameController = TextEditingController();
  final TextEditingController _amenityLocationController = TextEditingController();
  final TextEditingController _amenityPhoneController = TextEditingController();
  final TextEditingController _amenityDescController = TextEditingController();
  final TextEditingController _amenityOpeningController = TextEditingController();
  final TextEditingController _amenityClosingController = TextEditingController();
  final TextEditingController _amenityOperatingDaysController = TextEditingController();
  final TextEditingController _amenityServicesController = TextEditingController();
  final TextEditingController _amenityFacebookController = TextEditingController();
  final TextEditingController _amenityInstagramController = TextEditingController();
  final TextEditingController _amenityWhatsappController = TextEditingController();
  final TextEditingController _amenityWebsiteController = TextEditingController();
  String? _amenityImageUrl;
  File? _amenityImageFile;
  String? _amenityType;
  String? _editingAmenityId;
  List<String> _bizSelectedServices = [];
  List<String> _amenitySelectedServices = [];

  static const Set<String> _allowedBusinessCategories = {
    'STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF'
  };
  static const List<String> _propertyListingTypes = [
    'House',
    'Apartment',
    'Plot',
  ];
  static const List<String> _propertyPurposes = [
    'SALE',
    'RENTAL',
  ];
  static const List<String> _propertyStatuses = [
    'SUPER_HOT',
    'RENTAL',
    'FEATURED',
  ];
  static const Set<String> _allowedAmenityTypes = {
    'MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE', 'ADMIN'
  };

  static const Map<String, String> _serviceTypeIcons = {
    'LAUNDRY': 'assets/icons/laundry_header_icon.svg',
    'PLUMBER': 'assets/icons/plumber_header_icon.svg',
    'ELECTRICIAN': 'assets/icons/xxx.svg',
    'PAINTER': 'assets/icons/painter_header_icon.svg',
    'CARPENTER': 'assets/icons/carpenter_header_icon.svg',
    'BARBER': 'assets/icons/barber_header_icon.svg',
    'MAID': 'assets/icons/maid_header_icon.svg',
    'SALON': 'assets/icons/salon_header_icon.svg',
    'REAL_ESTATE': 'assets/icons/fluent_real_estate_filled.svg',
    'DOCTOR': 'assets/icons/header_doctor_icon.svg',
    'WATER': 'assets/icons/water_header_icon.svg',
    'GAS': 'assets/icons/gas_header_icon.svg',
  };

  @override
  void initState() {
    super.initState();
    _spVendorIdController.text = 'Auto-generated on save';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PartnerProvider>(context, listen: false);
      provider.fetchProfile();
      provider.fetchServiceProviders();
      provider.fetchBusinesses();
      provider.fetchAmenities();
      _loadServiceCategories();
    });
  }

  Future<void> _loadServiceCategories() async {
    final provider = Provider.of<PartnerProvider>(context, listen: false);
    final cats = await provider.fetchServiceCategories();
    if (mounted) {
      setState(() {
        _serviceCategories = cats;
      });
    }
  }

  String _normalizeSkillTag(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  Future<void> _loadSkillSuggestionsForType(String? serviceType) async {
    if (serviceType == null || serviceType.isEmpty) {
      if (mounted) {
        setState(() => _spSuggestedSkills = []);
      }
      return;
    }
    final provider = Provider.of<PartnerProvider>(context, listen: false);
    final suggestions = await provider.fetchServiceSkillSuggestions(serviceType);
    if (mounted) {
      setState(() {
        _spSuggestedSkills = suggestions;
      });
    }
  }

  void _addSkillTag(String rawValue) {
    final normalized = _normalizeSkillTag(rawValue);
    if (normalized.isEmpty) {
      // If a service is already selected, avoid showing a false validation error
      // when the add button is tapped with an empty input.
      if (_spSelectedSkills.isNotEmpty) {
        _spSkillInputController.clear();
        _spSkillFocusNode.requestFocus();
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a service before adding')),
        );
      }
      return;
    }
    if (_spSelectedSkills.any((s) => s.toLowerCase() == normalized.toLowerCase())) {
      _spSkillInputController.clear();
      _spSkillFocusNode.requestFocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$normalized" already added')),
        );
      }
      return;
    }
    setState(() {
      _spSelectedSkills = [..._spSelectedSkills, normalized];
      _spSkillInputController.clear();
    });
    _spSkillFocusNode.requestFocus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$normalized" added')),
      );
    }
  }

  void _removeSkillTag(String value) {
    setState(() {
      _spSelectedSkills = _spSelectedSkills
          .where((s) => s.toLowerCase() != value.toLowerCase())
          .toList();
    });
  }

  void _clearServiceProviderForm() {
    _spNameController.clear();
    _spPhoneController.clear();
    _spWhatsappController.clear();
    _spAddressController.clear();
    _spChargeController.clear();
    _spWorkingSinceController.clear();
    _spResponseTimeController.clear();
    _spVendorIdController.text = 'Auto-generated on save';
    _spDoctorIdController.clear();
    _spExperienceYearsController.clear();
    _spHospitalNameController.clear();
    _spConsultationChargeController.clear();
    _spPatientsCountController.clear();
    _spJobsCompletedController.clear();
    _spCityController.text = 'Lahore';
    _spSkillInputController.clear();
    setState(() {
      _editingServiceProviderId = null;
      _spServiceType = null;
      _spFollowEnabled = false;
      _spProfessionalProfileEnabled = false;
      _spImageUrl = null;
      _spImageFile = null;
      _spSelectedSkills = [];
      _spSuggestedSkills = [];
    });
  }

  Future<void> _startEditServiceProvider(ServiceProviderModel sp) async {
    _spNameController.text = sp.name;
    _spPhoneController.text = sp.phone ?? '';
    _spWhatsappController.text = sp.whatsapp ?? '';
    _spAddressController.text = sp.address ?? '';
    _spCityController.text = (sp.city?.trim().isNotEmpty ?? false) ? sp.city! : 'Lahore';
    _spChargeController.text = sp.serviceCharge?.toStringAsFixed(0) ?? '';
    _spWorkingSinceController.text = sp.workingSince ?? '';
    _spResponseTimeController.text = sp.responseTime ?? '';
    _spVendorIdController.text =
        (sp.vendorId?.trim().isNotEmpty ?? false) ? sp.vendorId! : 'Auto-generated on save';
    _spDoctorIdController.text = sp.doctorId ?? '';
    _spExperienceYearsController.text = sp.experienceYears?.toString() ?? '';
    _spHospitalNameController.text = sp.hospitalName ?? '';
    _spConsultationChargeController.text = sp.consultationCharge?.toStringAsFixed(0) ?? '';
    _spPatientsCountController.text = sp.patientsCount?.toString() ?? '';
    _spJobsCompletedController.text = sp.jobsCompleted.toString();
    _spSkillInputController.clear();

    setState(() {
      _editingServiceProviderId = sp.id;
      _spServiceType = sp.serviceType;
      _spFollowEnabled = sp.isFollowEnabled;
      _spProfessionalProfileEnabled = sp.isProfessionalProfileEnabled;
      _spSelectedSkills = List<String>.from(sp.skills);
    });
    await _loadSkillSuggestionsForType(sp.serviceType);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Editing ${sp.name}')),
      );
    }
  }

  void _syncLocalState(PartnerModel partner) {
    if (_profileSynced) return;
    _profileSynced = true;
    _isBusinessOpen = partner.isBusinessOpen;
    _selectedDays.addAll(partner.operatingDays);
    _followUs = partner.followUsEnabled;
    _facebookController.text = partner.facebookUrl ?? '';
    _instagramController.text = partner.instagramUrl ?? '';
    _whatsappController.text = partner.whatsapp ?? '';
    _websiteController.text = partner.websiteUrl ?? '';
    if (partner.phones.isNotEmpty) {
      _phoneController.text = partner.phones.first.phoneNumber;
    }
    final mapped = _mapBusinessTypeToDashboardCategory(partner.businessType);
    if (mapped != null) {
      _profileDashboardCategory = mapped;
      _dashboardCategory = mapped;
      _selectedCategory = mapped;
    }
  }

  String? _mapBusinessTypeToDashboardCategory(String? businessType) {
    final type = (businessType ?? '').trim().toUpperCase();
    switch (type) {
      case 'SERVICE_PROVIDER':
        return _catServices;
      case 'RETAIL_STORE':
      case 'RESTAURANT':
      case 'ONLINE_BUSINESS':
        return _catBusinesses;
      case 'OTHER':
        return _catAmenities;
      default:
        return null;
    }
  }

  void _setDashboardCategory(String? category) {
    final lockedCategory = _profileDashboardCategory;
    if (lockedCategory != null && category != null && category != lockedCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard category is fixed to "$lockedCategory" from signup business type.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final effectiveCategory = lockedCategory ?? category;
    setState(() {
      _dashboardCategory = effectiveCategory;
      _selectedCategory = effectiveCategory;
    });
    if (effectiveCategory == _catServices && _serviceCategories.isEmpty) {
      _loadServiceCategories();
    }
  }

  void _openRealEstateAgentSetup() {
    final pp = Provider.of<PartnerProvider>(context, listen: false);
    final partner = pp.partner;
    _setDashboardCategory(_catServices);
    setState(() {
      _spServiceType = 'REAL_ESTATE';
      _spProfessionalProfileEnabled = true;
      _spFollowEnabled = true;
      if (_spNameController.text.trim().isEmpty) {
        _spNameController.text = (partner?.businessName ?? '').trim();
      }
      if (_spPhoneController.text.trim().isEmpty && partner?.phones.isNotEmpty == true) {
        _spPhoneController.text = partner!.phones.first.phoneNumber;
      }
      if (_spAddressController.text.trim().isEmpty) {
        _spAddressController.text = (partner?.address ?? '').trim();
      }
      if (_spCityController.text.trim().isEmpty) {
        _spCityController.text = (partner?.city ?? 'Lahore').trim();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Real Estate Agent profile in Services section')),
    );
  }

  // Helper method to update partner profile image
  Future<void> _updatePartnerProfileImage() async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(context, Icons.camera_alt, 'Camera', 'camera'),
                    _buildImageSourceOption(context, Icons.photo_library, 'Gallery', 'gallery'),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );

      if (result != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: result == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          setState(() {
            _partnerProfileImage = File(pickedFile.path);
          });
          // Upload to backend
          if (mounted) {
            await Provider.of<PartnerProvider>(context, listen: false)
                .uploadProfilePhoto(pickedFile.path);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  Widget _buildImageSourceOption(BuildContext context, IconData icon, String label, String value) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0097B2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF0097B2)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Helper method to pick image
  Future<void> _pickImage({required bool isVideo, bool forPromotion = false}) async {
    try {
      final XFile? pickedFile;
      if (isVideo) {
        pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
      } else {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        if (forPromotion) {
          setState(() {
            _promotionImage = File(pickedFile!.path);
          });
        } else {
          // Upload to backend
          if (mounted) {
            await Provider.of<PartnerProvider>(context, listen: false)
                .uploadMedia(pickedFile.path);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Helper method to delete uploaded file
  void _deleteUploadedMedia(String mediaId) {
    Provider.of<PartnerProvider>(context, listen: false).deleteMedia(mediaId);
  }

  Future<void> _pickAndUploadProviderMedia({required bool isVideo}) async {
    final providerId = _galleryServiceProviderId;
    if (providerId == null || providerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service provider first')),
      );
      return;
    }

    try {
      int uploadedCount = 0;
      if (isVideo) {
        final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
        if (picked == null) return;
        final ok = await Provider.of<PartnerProvider>(context, listen: false).uploadProviderMedia(
          providerId,
          picked.path,
          mediaType: 'VIDEO',
        );
        if (ok) uploadedCount = 1;
      } else {
        final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);
        if (pickedFiles.isEmpty) return;
        for (final file in pickedFiles) {
          final ok = await Provider.of<PartnerProvider>(context, listen: false).uploadProviderMedia(
            providerId,
            file.path,
            mediaType: 'PHOTO',
          );
          if (ok) uploadedCount += 1;
        }
      }
      if (!mounted) return;
      await Provider.of<PartnerProvider>(context, listen: false)
          .fetchServiceProviderMedia(providerId, force: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploadedCount > 0
                ? '$uploadedCount media uploaded successfully'
                : 'Media upload failed',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error uploading provider media: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload media')),
      );
    }
  }

  Future<void> _deleteServiceProviderMedia(String providerId, String mediaId) async {
    final ok = await Provider.of<PartnerProvider>(context, listen: false)
        .deleteServiceProviderMedia(providerId, mediaId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Media deleted' : 'Failed to delete media')),
    );
  }

  Future<void> _deleteBusinessMedia(String mediaId) async {
    final ok = await Provider.of<PartnerProvider>(context, listen: false)
        .deleteBusinessMedia(mediaId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Media deleted' : 'Failed to delete media')),
    );
  }

  Future<void> _deleteAmenityMedia(String mediaId) async {
    final ok = await Provider.of<PartnerProvider>(context, listen: false)
        .deleteAmenityMedia(mediaId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Media deleted' : 'Failed to delete media')),
    );
  }

  bool _isVideoType(String mediaType) => mediaType.trim().toUpperCase() == 'VIDEO';

  Future<void> _openMediaUrl(String rawUrl) async {
    final url = Uri.parse(rawUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMediaThumb({
    required String fileUrl,
    required String mediaType,
    required double size,
    VoidCallback? onDelete,
  }) {
    final isVideo = _isVideoType(mediaType);
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(right: size * 0.2),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _openMediaUrl(fileUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.18),
                child: isVideo
                    ? Container(
                        color: const Color(0xFFDCE2EA),
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: const Color(0xFF375EF9),
                          size: size * 0.5,
                        ),
                      )
                    : Image.network(
                        fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFDCE2EA),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade600,
                            size: size * 0.45,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (onDelete != null)
            Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: const BoxDecoration(
                    color: Color(0xCCFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: size * 0.2,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _parseCsvList(String input) {
    return input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _parseDayCodes(String input) {
    final map = <String, String>{
      'su': 'Su',
      'sun': 'Su',
      'sunday': 'Su',
      'm': 'M',
      'mon': 'M',
      'monday': 'M',
      't': 'T',
      'tu': 'T',
      'tue': 'T',
      'tues': 'T',
      'tuesday': 'T',
      'w': 'W',
      'wed': 'W',
      'wednesday': 'W',
      'th': 'Th',
      'thu': 'Th',
      'thur': 'Th',
      'thurs': 'Th',
      'thursday': 'Th',
      'f': 'F',
      'fri': 'F',
      'friday': 'F',
      's': 'S',
      'sat': 'S',
      'saturday': 'S',
    };
    return _parseCsvList(input)
        .map((s) => map[s.toLowerCase()] ?? s)
        .where((s) => const ['Su', 'M', 'T', 'W', 'Th', 'F', 'S'].contains(s))
        .toList();
  }

  String? _normalizeUrlOrNull(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final withScheme = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || (!uri.hasScheme || uri.host.isEmpty)) return null;
    return withScheme;
  }

  bool _isValidTimeOrEmpty(String value) {
    final v = value.trim();
    if (v.isEmpty) return true;
    return RegExp(r'^\d{2}:\d{2}$').hasMatch(v);
  }

  List<_ServiceVisualOption> _businessServiceOptionsForCategory(String? category) {
    switch (category) {
      case 'STORE':
        return const [
          _ServiceVisualOption('Delivery', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Pickup', 'assets/images/tabler_shopping-cart-check.svg'),
          _ServiceVisualOption('Fast Service', 'assets/images/material-symbols_shopping-bag-speed.svg'),
          _ServiceVisualOption('Online Payment', 'assets/images/ic_round-payment.svg'),
        ];
      case 'SOLAR':
        return const [
          _ServiceVisualOption('Installation', 'assets/images/icon_building.svg'),
          _ServiceVisualOption('Site Survey', 'assets/images/icon_map.svg'),
          _ServiceVisualOption('Maintenance', 'assets/icons/jobs.svg'),
          _ServiceVisualOption('24/7 Support', 'assets/icons/call.svg'),
        ];
      case 'BANK':
        return const [
          _ServiceVisualOption('Cash Deposit', 'assets/images/icon_money_hand.svg'),
          _ServiceVisualOption('Online Banking', 'assets/images/data_usage_icon.svg'),
          _ServiceVisualOption('Bill Payments', 'assets/images/ic_round-payment.svg'),
          _ServiceVisualOption('Card Services', 'assets/images/icon_document_2.svg'),
        ];
      case 'RESTAURANT':
        return const [
          _ServiceVisualOption('Delivery', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Dine In', 'assets/icons/door_open_1.svg'),
          _ServiceVisualOption('Takeaway', 'assets/images/tabler_shopping-cart-check.svg'),
          _ServiceVisualOption('Online Payment', 'assets/images/ic_round-payment.svg'),
        ];
      case 'REAL_ESTATE':
        return const [
          _ServiceVisualOption('Bedroom', 'assets/images/icon_bed_2.svg'),
          _ServiceVisualOption('Bathroom', 'assets/images/icon_bath_shower_2.svg'),
          _ServiceVisualOption('Kitchen', 'assets/images/icon_kitchen.svg'),
          _ServiceVisualOption('Area (Sqft)', 'assets/images/icon_ruler_measure_2.svg'),
        ];
      case 'HOME_CHEF':
        return const [
          _ServiceVisualOption('Home Delivery', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Advance Booking', 'assets/icons/tdesign_time.svg'),
          _ServiceVisualOption('Custom Menu', 'assets/images/icon_document_2.svg'),
          _ServiceVisualOption('Online Payment', 'assets/images/ic_round-payment.svg'),
        ];
      default:
        return const [];
    }
  }

  void _clearBusinessForm() {
    _bizNameController.clear();
    _bizLocationController.clear();
    _bizPhoneController.clear();
    _bizDescController.clear();
    _bizOpeningController.clear();
    _bizClosingController.clear();
    _bizOperatingDaysController.clear();
    _bizServicesController.clear();
    _bizFacebookController.clear();
    _bizInstagramController.clear();
    _bizWhatsappController.clear();
    _bizWebsiteController.clear();
    _bizBedsController.clear();
    _bizBathsController.clear();
    _bizKitchenController.clear();
    _bizPriceController.clear();
    _bizSqftController.clear();
    setState(() {
      _editingBusinessId = null;
      _bizImageUrl = null;
      _bizImageFile = null;
      _bizCategory = null;
      _bizFollowEnabled = true;
      _bizPropertyType = null;
      _bizPropertyPurpose = null;
      _bizPropertyStatus = null;
      _bizRealEstateAgentId = null;
      _bizSelectedServices = [];
    });
  }

  void _clearAmenityForm() {
    _amenityNameController.clear();
    _amenityLocationController.clear();
    _amenityPhoneController.clear();
    _amenityDescController.clear();
    _amenityOpeningController.clear();
    _amenityClosingController.clear();
    _amenityOperatingDaysController.clear();
    _amenityServicesController.clear();
    _amenityFacebookController.clear();
    _amenityInstagramController.clear();
    _amenityWhatsappController.clear();
    _amenityWebsiteController.clear();
    setState(() {
      _editingAmenityId = null;
      _amenityImageUrl = null;
      _amenityImageFile = null;
      _amenityType = null;
      _amenitySelectedServices = [];
    });
  }

  void _startEditBusiness(BusinessModel biz) {
    final provider = Provider.of<PartnerProvider>(context, listen: false);
    final isProperty = biz.id.startsWith('property:');
    final category = biz.category.toUpperCase();
    String? editImageUrl = biz.imageUrl;

    _bizNameController.text = biz.name;
    _bizLocationController.text = biz.location ?? '';
    _bizPhoneController.text = biz.phone ?? '';
    _bizDescController.text = biz.description ?? '';
    _bizServicesController.clear();
    _bizFacebookController.text = biz.facebookUrl ?? '';
    _bizInstagramController.text = biz.instagramUrl ?? '';
    _bizWhatsappController.text = biz.whatsapp ?? '';
    _bizWebsiteController.text = biz.websiteUrl ?? '';
    _bizBedsController.clear();
    _bizBathsController.clear();
    _bizKitchenController.clear();
    _bizPriceController.clear();
    _bizSqftController.clear();

    String? propertyType;
    String? propertyPurpose;
    String? propertyStatus;
    String? propertyAgentId;
    if (isProperty) {
      final propertyId = biz.id.substring('property:'.length);
      final propertyIndex = provider.properties.indexWhere((p) => p.id == propertyId);
      final property = propertyIndex == -1 ? null : provider.properties[propertyIndex];
      if (property != null) {
        _bizNameController.text = property.title;
        _bizLocationController.text = property.location ?? '';
        _bizDescController.text = property.description ?? '';
        _bizPriceController.text = property.price?.toStringAsFixed(0) ?? '';
        _bizSqftController.text = property.sqft?.toStringAsFixed(0) ?? '';
        _bizBedsController.text = property.beds?.toString() ?? '';
        _bizBathsController.text = property.baths?.toString() ?? '';
        _bizKitchenController.text = property.kitchen?.toString() ?? '';
        propertyType = property.propertyType;
        propertyPurpose = property.purpose;
        propertyStatus = property.listingStatus;
        propertyAgentId = property.serviceProviderId;
        editImageUrl = property.mainImageUrl;
      }
    }

    setState(() {
      _editingBusinessId = biz.id;
      _bizCategory = category;
      _bizFollowEnabled = biz.isFollowEnabled;
      _bizPropertyType = category == 'REAL_ESTATE' ? (propertyType ?? 'House') : null;
      _bizPropertyPurpose = category == 'REAL_ESTATE' ? (propertyPurpose ?? 'RENTAL') : null;
      _bizPropertyStatus = category == 'REAL_ESTATE' ? (propertyStatus ?? 'FEATURED') : null;
      _bizRealEstateAgentId = category == 'REAL_ESTATE' ? propertyAgentId : null;
      _bizImageUrl = editImageUrl;
      _bizSelectedServices = List<String>.from(
        biz.servicesOffered.isNotEmpty
            ? biz.servicesOffered
            : _businessServiceOptionsForCategory(category).take(4).map((e) => e.label),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Editing ${biz.name}')),
      );
    }
  }

  void _startEditAmenity(AmenityModel amenity) {
    _amenityNameController.text = amenity.name;
    _amenityLocationController.text = amenity.location ?? '';
    _amenityPhoneController.text = amenity.phone ?? '';
    _amenityDescController.text = amenity.description ?? '';
    _amenityServicesController.clear();
    _amenityFacebookController.text = amenity.facebookUrl ?? '';
    _amenityInstagramController.text = amenity.instagramUrl ?? '';
    _amenityWhatsappController.text = amenity.whatsapp ?? '';
    _amenityWebsiteController.text = amenity.websiteUrl ?? '';

    setState(() {
      _editingAmenityId = amenity.id;
      _amenityType = amenity.amenityType.toUpperCase();
      _amenityImageUrl = amenity.imageUrl;
      _amenitySelectedServices = List<String>.from(
        amenity.servicesOffered.isNotEmpty
            ? amenity.servicesOffered
            : _amenityServiceOptionsForType(amenity.amenityType.toUpperCase())
                .take(4)
                .map((e) => e.label),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Editing ${amenity.name}')),
      );
    }
  }

  List<_ServiceVisualOption> _amenityServiceOptionsForType(String? amenityType) {
    switch (amenityType) {
      case 'MASJID':
        return const [
          _ServiceVisualOption('Wudu Area', 'assets/icons/door_open_1.svg'),
          _ServiceVisualOption('Parking', 'assets/images/location_pin_icon.svg'),
          _ServiceVisualOption('Air Conditioned', 'assets/images/data_usage_icon.svg'),
          _ServiceVisualOption('Women Area', 'assets/images/icon_building.svg'),
        ];
      case 'PARK':
        return const [
          _ServiceVisualOption('Parking', 'assets/images/location_pin_icon.svg'),
          _ServiceVisualOption('Walking Track', 'assets/images/icon_map.svg'),
          _ServiceVisualOption('Play Area', 'assets/images/park_icon.svg'),
          _ServiceVisualOption('Security', 'assets/icons/check_circle_icon.svg'),
        ];
      case 'GYM':
        return const [
          _ServiceVisualOption('Trainer Available', 'assets/icons/jobs.svg'),
          _ServiceVisualOption('Cardio Zone', 'assets/images/health_icon.svg'),
          _ServiceVisualOption('Locker Room', 'assets/icons/door_open_2.svg'),
          _ServiceVisualOption('Parking', 'assets/images/location_pin_icon.svg'),
        ];
      case 'HEALTHCARE':
        return const [
          _ServiceVisualOption('Emergency', 'assets/images/health_icon.svg'),
          _ServiceVisualOption('Lab Tests', 'assets/images/icon_document_2.svg'),
          _ServiceVisualOption('Pharmacy', 'assets/images/pharmacy_icon.svg'),
          _ServiceVisualOption('Online Reports', 'assets/images/data_usage_icon.svg'),
        ];
      case 'SCHOOL':
        return const [
          _ServiceVisualOption('Transport', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Library', 'assets/images/icon_document_2.svg'),
          _ServiceVisualOption('Labs', 'assets/images/education_icon.svg'),
          _ServiceVisualOption('Sports', 'assets/images/park_icon.svg'),
        ];
      case 'PHARMACY':
        return const [
          _ServiceVisualOption('Delivery', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Prescription', 'assets/images/icon_document_2.svg'),
          _ServiceVisualOption('BP Check', 'assets/images/health_icon.svg'),
          _ServiceVisualOption('Online Payment', 'assets/images/ic_round-payment.svg'),
        ];
      case 'CAFE':
        return const [
          _ServiceVisualOption('Dine In', 'assets/icons/door_open_1.svg'),
          _ServiceVisualOption('Takeaway', 'assets/images/tabler_shopping-cart-check.svg'),
          _ServiceVisualOption('Delivery', 'assets/images/iconamoon_delivery-fill.svg'),
          _ServiceVisualOption('Free WiFi', 'assets/images/data_usage_icon.svg'),
        ];
      case 'ADMIN':
        return const [
          _ServiceVisualOption('Public Support', 'assets/icons/call.svg'),
          _ServiceVisualOption('Complaint Desk', 'assets/images/icon_document_2.svg'),
          _ServiceVisualOption('Guidance', 'assets/icons/map.svg'),
          _ServiceVisualOption('Help Line', 'assets/icons/phone_icon.svg'),
        ];
      default:
        return const [];
    }
  }

  List<String> _mergeServices(List<String> selected, String additionalCsv) {
    final merged = <String>[
      ...selected,
      ..._parseCsvList(additionalCsv),
    ];
    final seen = <String>{};
    final out = <String>[];
    for (final item in merged) {
      final key = item.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      out.add(item.trim());
      if (out.length >= 30) break;
    }
    return out;
  }

  bool get _isRealEstateCategorySelected =>
      (_bizCategory ?? '').trim().toUpperCase() == 'REAL_ESTATE';

  String _normalizeServiceType(String? value) {
    return (value ?? '')
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  bool _isCompleteRealEstateAgent(ServiceProviderModel sp) {
    if (_normalizeServiceType(sp.serviceType) != 'REAL_ESTATE') return false;
    if (sp.name.trim().isEmpty) return false;
    if ((sp.phone ?? '').trim().isEmpty) return false;
    final hasAddress = (sp.address ?? '').trim().isNotEmpty || (sp.city ?? '').trim().isNotEmpty;
    return hasAddress;
  }

  List<ServiceProviderModel> _realEstateAgentsAny(PartnerProvider provider) {
    return provider.serviceProviders
        .where((sp) => _normalizeServiceType(sp.serviceType) == 'REAL_ESTATE')
        .toList();
  }

  List<ServiceProviderModel> _realEstateAgents(PartnerProvider provider) {
    return _realEstateAgentsAny(provider).where(_isCompleteRealEstateAgent).toList();
  }

  Map<String, dynamic>? _buildBusinessPayload() {
    final partner = Provider.of<PartnerProvider>(context, listen: false).partner;
    final name = _bizNameController.text.trim();
    final category = (_bizCategory ?? '').trim().toUpperCase();
    if (name.isEmpty || !_allowedBusinessCategories.contains(category)) {
      return null;
    }

    final opening = (partner?.openingTime ?? '').trim();
    final closing = (partner?.closingTime ?? '').trim();
    if (!_isValidTimeOrEmpty(opening) || !_isValidTimeOrEmpty(closing)) {
      return {'_validationError': 'Opening/Closing time must be HH:mm format'};
    }

    final services = _mergeServices(_bizSelectedServices, _bizServicesController.text);
    if (category == 'REAL_ESTATE') {
      final pp = Provider.of<PartnerProvider>(context, listen: false);
      final allAgents = _realEstateAgentsAny(pp);
      if (allAgents.isEmpty) {
        return {'_validationError': 'Create a Real Estate Agent profile first'};
      }

      final selectedAgentId = (_bizRealEstateAgentId ?? '').trim();
      ServiceProviderModel? selectedAgent;
      for (final agent in allAgents) {
        if (agent.id == selectedAgentId) {
          selectedAgent = agent;
          break;
        }
      }
      if (selectedAgent == null) {
        return {'_validationError': 'Real Estate Agent profile is required'};
      }
      if (!_isCompleteRealEstateAgent(selectedAgent)) {
        return {
          '_validationError':
              'Selected agent profile is incomplete. Please add phone and address/city.',
        };
      }

      final propertyType = (_bizPropertyType ?? '').trim();
      if (propertyType.isEmpty) {
        return {'_validationError': 'Property type is required for Real Estate'};
      }
      final purpose = (_bizPropertyPurpose ?? '').trim().toUpperCase();
      if (purpose.isEmpty) {
        return {'_validationError': 'Purpose is required for Real Estate'};
      }
      final listingStatus = (_bizPropertyStatus ?? '').trim().toUpperCase();
      if (listingStatus.isEmpty) {
        return {'_validationError': 'Property status is required'};
      }
      if (_bizLocationController.text.trim().isEmpty) {
        return {'_validationError': 'Property location is required for Real Estate'};
      }

      final beds = int.tryParse(_bizBedsController.text.trim());
      final baths = int.tryParse(_bizBathsController.text.trim());
      final kitchen = int.tryParse(_bizKitchenController.text.trim());
      final price = double.tryParse(_bizPriceController.text.trim());
      final sqft = double.tryParse(_bizSqftController.text.trim());

      return {
        'name': name,
        'category': category,
        'isFollowEnabled': _bizFollowEnabled,
        'location': _bizLocationController.text.trim(),
        if (_bizPhoneController.text.trim().isNotEmpty) 'phone': _bizPhoneController.text.trim(),
        if (_bizDescController.text.trim().isNotEmpty) 'description': _bizDescController.text.trim(),
        if (_bizImageUrl != null) 'imageUrl': _bizImageUrl,
        'serviceProviderId': selectedAgentId,
        'propertyType': propertyType,
        'purpose': purpose,
        'listingStatus': listingStatus,
        if (beds != null) 'beds': beds,
        if (baths != null) 'baths': baths,
        if (kitchen != null) 'kitchen': kitchen,
        if (price != null) 'price': price,
        if (sqft != null) 'sqft': sqft,
        if (services.isNotEmpty) 'propertyHighlights': services,
        if (_bizWhatsappController.text.trim().isNotEmpty) 'whatsapp': _bizWhatsappController.text.trim(),
        if (_normalizeUrlOrNull(_bizWebsiteController.text) != null)
          'websiteUrl': _normalizeUrlOrNull(_bizWebsiteController.text),
      };
    }

    return {
      'name': name,
      'category': category,
      'isFollowEnabled': _bizFollowEnabled,
      if (_bizLocationController.text.trim().isNotEmpty) 'location': _bizLocationController.text.trim(),
      if (_bizPhoneController.text.trim().isNotEmpty) 'phone': _bizPhoneController.text.trim(),
      if (_bizDescController.text.trim().isNotEmpty) 'description': _bizDescController.text.trim(),
      if (_bizImageUrl != null) 'imageUrl': _bizImageUrl,
      if (opening.isNotEmpty) 'openingTime': opening,
      if (closing.isNotEmpty) 'closingTime': closing,
      if (_selectedDays.isNotEmpty) 'operatingDays': _selectedDays.toList(),
      if (services.isNotEmpty) 'servicesOffered': services,
      if (_normalizeUrlOrNull(_bizFacebookController.text) != null)
        'facebookUrl': _normalizeUrlOrNull(_bizFacebookController.text),
      if (_normalizeUrlOrNull(_bizInstagramController.text) != null)
        'instagramUrl': _normalizeUrlOrNull(_bizInstagramController.text),
      if (_bizWhatsappController.text.trim().isNotEmpty) 'whatsapp': _bizWhatsappController.text.trim(),
      if (_normalizeUrlOrNull(_bizWebsiteController.text) != null)
        'websiteUrl': _normalizeUrlOrNull(_bizWebsiteController.text),
    };
  }

  Map<String, dynamic>? _buildAmenityPayload() {
    final partner = Provider.of<PartnerProvider>(context, listen: false).partner;
    final name = _amenityNameController.text.trim();
    final amenityType = (_amenityType ?? '').trim().toUpperCase();
    if (name.isEmpty || !_allowedAmenityTypes.contains(amenityType)) {
      return null;
    }

    final opening = (partner?.openingTime ?? '').trim();
    final closing = (partner?.closingTime ?? '').trim();
    if (!_isValidTimeOrEmpty(opening) || !_isValidTimeOrEmpty(closing)) {
      return {'_validationError': 'Opening/Closing time must be HH:mm format'};
    }

    final services = _mergeServices(_amenitySelectedServices, _amenityServicesController.text);

    return {
      'name': name,
      'amenityType': amenityType,
      if (_amenityLocationController.text.trim().isNotEmpty) 'location': _amenityLocationController.text.trim(),
      if (_amenityPhoneController.text.trim().isNotEmpty) 'phone': _amenityPhoneController.text.trim(),
      if (_amenityDescController.text.trim().isNotEmpty) 'description': _amenityDescController.text.trim(),
      if (_amenityImageUrl != null) 'imageUrl': _amenityImageUrl,
      if (opening.isNotEmpty) 'openingTime': opening,
      if (closing.isNotEmpty) 'closingTime': closing,
      if (_selectedDays.isNotEmpty) 'operatingDays': _selectedDays.toList(),
      if (services.isNotEmpty) 'servicesOffered': services,
      if (_normalizeUrlOrNull(_amenityFacebookController.text) != null)
        'facebookUrl': _normalizeUrlOrNull(_amenityFacebookController.text),
      if (_normalizeUrlOrNull(_amenityInstagramController.text) != null)
        'instagramUrl': _normalizeUrlOrNull(_amenityInstagramController.text),
      if (_amenityWhatsappController.text.trim().isNotEmpty) 'whatsapp': _amenityWhatsappController.text.trim(),
      if (_normalizeUrlOrNull(_amenityWebsiteController.text) != null)
        'websiteUrl': _normalizeUrlOrNull(_amenityWebsiteController.text),
    };
  }

  String? _resolveCategoryIdForServiceType(String serviceType) {
    const slugByType = <String, String>{
      'LAUNDRY': 'laundry',
      'PLUMBER': 'plumber',
      'ELECTRICIAN': 'electrician',
      'PAINTER': 'painter',
      'CARPENTER': 'carpenter',
      'BARBER': 'barber',
      'MAID': 'maid',
      'SALON': 'salon',
      'REAL_ESTATE': 'real-estate',
      'DOCTOR': 'doctor',
      'WATER': 'water',
      'GAS': 'gas',
    };

    final expectedSlug = slugByType[serviceType];
    if (expectedSlug == null) return null;
    for (final c in _serviceCategories) {
      final slug = (c['slug'] ?? '').toString().toLowerCase();
      if (slug == expectedSlug) {
        final id = c['id'];
        if (id is String && id.isNotEmpty) return id;
      }
    }
    // Fallback: resolve by category name if slug is unavailable.
    final normalizedExpected = expectedSlug.replaceAll('-', ' ');
    for (final c in _serviceCategories) {
      final name = (c['name'] ?? '').toString().toLowerCase().trim();
      if (name == normalizedExpected) {
        final id = c['id'];
        if (id is String && id.isNotEmpty) return id;
      }
    }
    return null;
  }

  Future<void> _pickServiceProviderImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      setState(() {
        _spImageFile = File(pickedFile.path);
      });
      final url = await Provider.of<PartnerProvider>(context, listen: false)
          .uploadServiceProviderImage(pickedFile.path);
      if (mounted && url != null) {
        setState(() {
          _spImageUrl = url;
        });
      }
    } catch (e) {
      debugPrint('Error uploading service provider image: $e');
    }
  }

  Future<void> _pickBusinessImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      setState(() {
        _bizImageFile = File(pickedFile.path);
      });
      final url = await Provider.of<PartnerProvider>(context, listen: false)
          .uploadBusinessImage(pickedFile.path);
      if (mounted && url != null) {
        setState(() {
          _bizImageUrl = url;
        });
        final editingId = _editingBusinessId;
        if (editingId != null && editingId.isNotEmpty) {
          final payload = _buildBusinessPayload();
          if (payload != null && payload['_validationError'] == null) {
            final ok = await Provider.of<PartnerProvider>(context, listen: false)
                .updateBusiness(editingId, payload);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? 'Business image auto-saved'
                      : 'Image uploaded but auto-save failed',
                ),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded. Complete required fields to auto-save'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error uploading business image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload business image')),
      );
    }
  }

  Future<void> _pickAmenityImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      setState(() {
        _amenityImageFile = File(pickedFile.path);
      });
      final url = await Provider.of<PartnerProvider>(context, listen: false)
          .uploadAmenityImage(pickedFile.path);
      if (mounted && url != null) {
        setState(() {
          _amenityImageUrl = url;
        });
        final editingId = _editingAmenityId;
        if (editingId != null && editingId.isNotEmpty) {
          final payload = _buildAmenityPayload();
          if (payload != null && payload['_validationError'] == null) {
            final ok = await Provider.of<PartnerProvider>(context, listen: false)
                .updateAmenity(editingId, payload);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? 'Amenity image auto-saved'
                      : 'Image uploaded but auto-save failed',
                ),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded. Complete required fields to auto-save'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error uploading amenity image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload amenity image')),
      );
    }
  }

  Future<void> _uploadBusinessMedia(String businessId, {required bool isVideo}) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final ok = await Provider.of<PartnerProvider>(context, listen: false)
          .uploadBusinessMedia(businessId, pickedFile.path, mediaType: isVideo ? 'VIDEO' : 'PHOTO');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Business media uploaded' : 'Business media upload failed')),
      );
    } catch (e) {
      debugPrint('Error uploading business media: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload business media')),
      );
    }
  }

  Future<void> _uploadAmenityMedia(String amenityId, {required bool isVideo}) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final ok = await Provider.of<PartnerProvider>(context, listen: false)
          .uploadAmenityMedia(amenityId, pickedFile.path, mediaType: isVideo ? 'VIDEO' : 'PHOTO');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Amenity media uploaded' : 'Amenity media upload failed')),
      );
    } catch (e) {
      debugPrint('Error uploading amenity media: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload amenity media')),
      );
    }
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
        child: Consumer<PartnerProvider>(
          builder: (context, partnerProvider, _) {
            final partner = partnerProvider.partner;

            // Show loading spinner on initial load
            if (partnerProvider.isLoading && partner == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0097B2)),
              );
            }

            // Show error with retry
            if (partnerProvider.error != null && partner == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Color(0xFFE74C3C)),
                    const SizedBox(height: 16),
                    Text(partnerProvider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => partnerProvider.fetchProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Sync local state from partner data once
            if (partner != null) {
              _syncLocalState(partner);
              final status = partner.status.trim().toUpperCase();
              if (status != 'APPROVED') {
                return _buildAccountStatusGate(context, partner, scale);
              }
            }

            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header with curved background
                      _buildHeader(scale),

                      SizedBox(height: 14 * scale),

                      // Scrollable content area
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15 * scale),
                            child: Column(
                              children: [
                                // Profile section with overlap

                                SizedBox(height: 40 * scale),

                                // Partner card
                                _buildPartnerCard(context, scale),

                                SizedBox(height: 20 * scale),

                                // Category selection card
                                _buildCategorySelectionCard(context, scale),

                                if (_dashboardCategory != null) ...[
                                  SizedBox(height: 20 * scale),

                                  _buildDashboardDropdownSection(
                                    title: 'Business timings',
                                    subtitle: 'Control your working hours',
                                    expanded: _expandBusinessTimings,
                                    onToggle: () => setState(() => _expandBusinessTimings = !_expandBusinessTimings),
                                    scale: scale,
                                    child: _buildBusinessTimingsCard(context, scale, showSectionHeader: false),
                                  ),

                                  SizedBox(height: 20 * scale),

                                  _buildDashboardDropdownSection(
                                    title: 'Business Address',
                                    subtitle: 'Set your precise business location',
                                    expanded: _expandBusinessAddress,
                                    onToggle: () => setState(() => _expandBusinessAddress = !_expandBusinessAddress),
                                    scale: scale,
                                    child: _buildBusinessAddressCard(context, scale, showSectionHeader: false),
                                  ),

                                  SizedBox(height: 20 * scale),

                                  _buildDashboardDropdownSection(
                                    title: 'Contact Information',
                                    subtitle: 'Enter your business mobile number',
                                    expanded: _expandContactInfo,
                                    onToggle: () => setState(() => _expandContactInfo = !_expandContactInfo),
                                    scale: scale,
                                    child: _buildContactInformationCard(context, scale, showSectionHeader: false),
                                  ),

                                  SizedBox(height: 20 * scale),

                                  _buildDashboardDropdownSection(
                                    title: 'General Settings',
                                    subtitle: 'See your customer rating and reviews',
                                    expanded: _expandGeneralSettings,
                                    onToggle: () => setState(() => _expandGeneralSettings = !_expandGeneralSettings),
                                    scale: scale,
                                    child: _buildGeneralSettingsCard(context, scale, showSectionHeader: false),
                                  ),

                                  SizedBox(height: 20 * scale),

                                  _buildDashboardDropdownSection(
                                    title: 'Media Upload',
                                    subtitle: 'Showcase your business to customers',
                                    expanded: _expandMediaUpload,
                                    onToggle: () => setState(() => _expandMediaUpload = !_expandMediaUpload),
                                    scale: scale,
                                    child: _buildMediaUploadCard(context, scale),
                                  ),

                                  SizedBox(height: 20 * scale),

                                  if (_dashboardCategory == _catServices) ...[
                                    _buildMyServicesCard(context, scale),
                                    SizedBox(height: 20 * scale),
                                  ],

                                  if (_dashboardCategory == _catBusinesses) ...[
                                    _buildMyBusinessesCard(context, scale),
                                    SizedBox(height: 20 * scale),
                                  ],

                                  if (_dashboardCategory == _catAmenities) ...[
                                    _buildMyAmenitiesCard(context, scale),
                                    SizedBox(height: 20 * scale),
                                  ],

                                  if (_dashboardCategory == _catBusinesses) ...[
                                    _buildDashboardDropdownSection(
                                      title: 'Promotions',
                                      subtitle: 'Create offers and discounts',
                                      expanded: _expandPromotions,
                                      onToggle: () => setState(() => _expandPromotions = !_expandPromotions),
                                      scale: scale,
                                      child: _buildPromotionsCard(context, scale),
                                    ),
                                    SizedBox(height: 30 * scale),
                                  ],

                                  // Share the application
                                  _buildShareApplication(context, scale),

                                  SizedBox(height: 20 * scale),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 110 * scale,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProfileAvatar(partner, scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    _websiteController.dispose();
    _promotionTitleController.dispose();
    _promotionPriceController.dispose();
    _promotionDiscountController.dispose();
    _promotionDescriptionController.dispose();
    _spNameController.dispose();
    _spPhoneController.dispose();
    _spWhatsappController.dispose();
    _spAddressController.dispose();
    _spCityController.dispose();
    _spChargeController.dispose();
    _spWorkingSinceController.dispose();
    _spResponseTimeController.dispose();
    _spVendorIdController.dispose();
    _spDoctorIdController.dispose();
    _spExperienceYearsController.dispose();
    _spHospitalNameController.dispose();
    _spConsultationChargeController.dispose();
    _spPatientsCountController.dispose();
    _spJobsCompletedController.dispose();
    _spSkillInputController.dispose();
    _spSkillFocusNode.dispose();
    _bizNameController.dispose();
    _bizLocationController.dispose();
    _bizPhoneController.dispose();
    _bizDescController.dispose();
    _bizOpeningController.dispose();
    _bizClosingController.dispose();
    _bizOperatingDaysController.dispose();
    _bizServicesController.dispose();
    _bizFacebookController.dispose();
    _bizInstagramController.dispose();
    _bizWhatsappController.dispose();
    _bizWebsiteController.dispose();
    _bizBedsController.dispose();
    _bizBathsController.dispose();
    _bizKitchenController.dispose();
    _bizPriceController.dispose();
    _bizSqftController.dispose();
    _amenityNameController.dispose();
    _amenityLocationController.dispose();
    _amenityPhoneController.dispose();
    _amenityDescController.dispose();
    _amenityOpeningController.dispose();
    _amenityClosingController.dispose();
    _amenityOperatingDaysController.dispose();
    _amenityServicesController.dispose();
    _amenityFacebookController.dispose();
    _amenityInstagramController.dispose();
    _amenityWhatsappController.dispose();
    _amenityWebsiteController.dispose();
    super.dispose();
  }

  Widget _buildAccountStatusGate(
    BuildContext context,
    PartnerModel partner,
    double scale,
  ) {
    final status = partner.status.trim().toUpperCase();
    final isSuspended = status == 'SUSPENDED';
    final title = isSuspended ? 'Account Suspended' : 'Application Under Review';
    final subtitle = isSuspended
        ? 'Your partner account is suspended. Please contact support.'
        : 'Your account is pending approval. You can log in, but dashboard actions will unlock after approval.';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuspended ? Icons.block_rounded : Icons.hourglass_top_rounded,
              size: 56 * scale,
              color: isSuspended
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF0097B2),
            ),
            SizedBox(height: 14 * scale),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5E5E5E),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20 * scale),
            OutlinedButton(
              onPressed: () =>
                  Provider.of<PartnerProvider>(context, listen: false).fetchProfile(),
              child: const Text('Refresh Status'),
            ),
            SizedBox(height: 10 * scale),
            TextButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/partner-login',
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(PartnerModel? partner, double scale) {
    final photoUrl = partner?.profilePhotoUrl;
    if (_partnerProfileImage != null) {
      return ClipOval(
        child: Image.file(
          _partnerProfileImage!,
          width: 120 * scale,
          height: 120 * scale,
          fit: BoxFit.cover,
        ),
      );
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 120 * scale,
          height: 120 * scale,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/partner_login_profile.png',
            width: 120 * scale,
            height: 120 * scale,
          ),
        ),
      );
    }
    return Image.asset(
      'assets/images/partner_login_profile.png',
      width: 120 * scale,
      height: 120 * scale,
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      width: double.infinity,
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
              style: GoogleFonts.inter(
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

  Widget _buildPartnerCard(BuildContext context, double scale) {
    final partner = Provider.of<PartnerProvider>(context, listen: false).partner;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with "1 CONNECT" text and camera icon
          GestureDetector(
            onTap: _updatePartnerProfileImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52 * scale,
                  height: 52 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFF044870), width: 2 * scale),
                    image: _partnerProfileImage != null
                        ? DecorationImage(
                            image: FileImage(_partnerProfileImage!),
                            fit: BoxFit.cover,
                          )
                        : (partner?.profilePhotoUrl != null && partner!.profilePhotoUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(partner.profilePhotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_partnerProfileImage == null && (partner?.profilePhotoUrl == null || partner!.profilePhotoUrl!.isEmpty))
                      ? Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '1 ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2388FF),
                                  ),
                                ),
                                TextSpan(
                                  text: 'CONNECT',
                                  style: GoogleFonts.inter(
                                    fontSize: 8 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0097B2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18 * scale,
                    height: 18 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF044870),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2 * scale),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 10 * scale,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          // Business name + Business ID
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale, vertical: 5 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner?.businessName ?? 'Business Name',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14 * scale,
                          color: const Color(0xFF19213D),
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'ID: ${partner?.businessId ?? ''}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * scale,
                          color: const Color(0xFF6D758F),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Logout
                  GestureDetector(
                    onTap: () async {
                      Provider.of<PartnerProvider>(context, listen: false).clear();
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/partner-login', (route) => false);
                      }
                    },
                    child: Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12 * scale,
                        color: const Color(0xFFE74C3C),
                      ),
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

  Widget _buildCategorySelectionCard(BuildContext context, double scale) {
    final lockedCategory = _profileDashboardCategory;
    final isCategoryLocked = lockedCategory != null;

    Widget categoryTile(String label, IconData icon) {
      final isSelected = _dashboardCategory == label;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (isCategoryLocked && label != lockedCategory) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Category locked to "$lockedCategory" based on signup business type.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            _setDashboardCategory(label);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: isSelected ? const Color(0xFF0097B2) : const Color(0xFFCBD0DC),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22 * scale, color: const Color(0xFF0097B2)),
                SizedBox(height: 6 * scale),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * scale,
                    color: const Color(0xFF19213D),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Category',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16 * scale,
              color: const Color(0xFF19213D),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Choose the type you want to manage',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 12 * scale,
              color: const Color(0xFF6D758F),
            ),
          ),
          SizedBox(height: 12 * scale),
          if (isCategoryLocked) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7FA),
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: const Color(0xFF0097B2).withOpacity(0.3)),
              ),
              child: Text(
                'Category fixed from signup: $lockedCategory',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: const Color(0xFF19213D),
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
          ],
          Row(
            children: [
              categoryTile(_catServices, Icons.medical_services_outlined),
              SizedBox(width: 10 * scale),
              categoryTile(_catBusinesses, Icons.store_outlined),
              SizedBox(width: 10 * scale),
              categoryTile(_catAmenities, Icons.park_outlined),
            ],
          ),
          if (_dashboardCategory != null) ...[
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Text(
                  'Selected: $_dashboardCategory',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * scale,
                    color: const Color(0xFF19213D),
                  ),
                ),
                const Spacer(),
                if (!isCategoryLocked)
                  GestureDetector(
                    onTap: () => _setDashboardCategory(null),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696969),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        'Change',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessTimingsCard(BuildContext context, double scale, {bool showSectionHeader = true}) {
    final partner = context.watch<PartnerProvider>().partner;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionHeader) ...[
            Text(
              'Business timings',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                color: const Color(0xFF19213D),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Control your working hours and business presence',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12 * scale,
                color: const Color(0xFF6D758F),
              ),
            ),
            SizedBox(height: 20 * scale),
          ],

          // Business Open/Closed toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Open/Closed',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14 * scale,
                  color: const Color(0xFF19213D),
                ),
              ),
              Switch(
                value: _isBusinessOpen,
                onChanged: (value) {
                  setState(() {
                    _isBusinessOpen = value;
                  });
                  Provider.of<PartnerProvider>(context, listen: false)
                      .toggleBusinessOpen(value)
                      .then((success) {
                    if (!success && mounted) {
                      setState(() => _isBusinessOpen = !value);
                    }
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Color(0xFF02A6C3),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Opening time
          _buildTimeRow(
            context: context,
            scale: scale,
            label: 'Opening time',
            value: _formatTimeForDisplay(partner?.openingTime, fallback: '10:00'),
            onEdit: () => _editTime(context, isOpening: true),
          ),
          SizedBox(height: 12 * scale),

          // Closing time
          _buildTimeRow(
            context: context,
            scale: scale,
            label: 'Closing time',
            value: _formatTimeForDisplay(partner?.closingTime, fallback: '22:00'),
            onEdit: () => _editTime(context, isOpening: false),
          ),
          SizedBox(height: 20 * scale),

          // Select working days
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                size: 20 * scale,
                color: const Color(0xFF0097B2),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Select your business working days',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14 * scale,
                  color: const Color(0xFF19213D),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),

          // Days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayButton('Su', scale, _selectedDays.contains('Su')),
              _buildDayButton('M', scale, _selectedDays.contains('M')),
              _buildDayButton('T', scale, _selectedDays.contains('T')),
              _buildDayButton('W', scale, _selectedDays.contains('W')),
              _buildDayButton('Th', scale, _selectedDays.contains('Th')),
              _buildDayButton('F', scale, _selectedDays.contains('F')),
              _buildDayButton('S', scale, _selectedDays.contains('S')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required BuildContext context,
    required double scale,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 20 * scale,
          color: const Color(0xFF0097B2),
        ),
        SizedBox(width: 8 * scale),
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14 * scale,
            color: const Color(0xFF19213D),
          ),
        ),
        Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14 * scale,
            color: const Color(0xFFE74C3C),
          ),
        ),
        SizedBox(width: 12 * scale),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF696969),
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12 * scale,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeForDisplay(String? raw, {required String fallback}) {
    final source = (raw ?? '').trim();
    final candidate = source.isEmpty ? fallback : source;
    try {
      final parsed = DateFormat('HH:mm').parseStrict(candidate);
      return DateFormat.jm().format(parsed);
    } catch (_) {
      return candidate;
    }
  }

  Widget _buildDashboardDropdownSection({
    required String title,
    required String subtitle,
    required bool expanded,
    required VoidCallback onToggle,
    required double scale,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * scale,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 13 * scale,
                          color: const Color(0xFF3F3F3F),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF1A1A1A),
                  size: 24 * scale,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            SizedBox(height: 12 * scale),
            child,
          ],
        ],
      ),
    );
  }

  Future<void> _editTime(BuildContext context, {required bool isOpening}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final field = isOpening ? 'openingTime' : 'closingTime';
      final ok = await Provider.of<PartnerProvider>(context, listen: false)
          .updateProfile({field: formatted});
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update time')),
        );
      }
    }
  }

  Future<void> _showEditAddressDialog(BuildContext context) async {
    final partnerProvider = Provider.of<PartnerProvider>(context, listen: false);
    final partner = partnerProvider.partner;
    final addressCtrl = TextEditingController(text: partner?.address ?? '');
    final areaCtrl = TextEditingController(text: partner?.area ?? '');
    final cityCtrl = TextEditingController(text: partner?.city ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: areaCtrl,
              decoration: const InputDecoration(labelText: 'Area'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'City'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true && mounted) {
      await partnerProvider.updateProfile({
        'address': addressCtrl.text.trim(),
        'area': areaCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
      });
    }

    addressCtrl.dispose();
    areaCtrl.dispose();
    cityCtrl.dispose();
  }

  Future<void> _showAddContactDialog(BuildContext context) async {
    final partnerProvider = Provider.of<PartnerProvider>(context, listen: false);
    final phoneCtrl = TextEditingController();
    Country selected = _selectedCountry;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: ctx,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setDialogState(() {
                        selected = country;
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selected.flagEmoji),
                      const SizedBox(width: 6),
                      Text('+${selected.phoneCode}'),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final number = phoneCtrl.text.trim();
      if (number.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number is required')),
        );
      } else {
        final existing = partnerProvider.partner?.phones ?? [];
        final phones = [
          ...existing,
          PartnerPhone(
            phoneNumber: number,
            countryCode: '+${selected.phoneCode}',
            isPrimary: existing.isEmpty,
          ),
        ];
        final ok = await partnerProvider.updatePhones(phones);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ok ? 'Contact added' : 'Failed to add contact')),
          );
        }
      }
    }

    phoneCtrl.dispose();
  }

  Widget _buildDayButton(String day, double scale, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedDays.contains(day)) {
            _selectedDays.remove(day);
          } else {
            _selectedDays.add(day);
          }
        });
      },
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF0097B2) : Colors.white,
          border: Border.all(
            color: const Color(0xFF0097B2),
            width: 1 * scale,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
              color: isSelected ? Colors.white : const Color(0xFF0097B2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessAddressCard(BuildContext context, double scale, {bool showSectionHeader = true}) {
    final partner = Provider.of<PartnerProvider>(context, listen: false).partner;
    final addressLine1 = partner?.address ?? 'No address set';
    final addressLine2 = partner?.area ?? '';
    final addressLine3 = [partner?.city, partner?.country].where((s) => s != null && s.isNotEmpty).join(', ');
    final fullAddress = [addressLine1, addressLine2, addressLine3].where((s) => s.isNotEmpty).join(', ');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionHeader) ...[
            Text(
              'Business Address',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                color: const Color(0xFF19213D),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Set your precise business location to help customers find you easily',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12 * scale,
                color: const Color(0xFF6D758F),
              ),
            ),
            SizedBox(height: 16 * scale),
          ],

          // Address section with buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location pin icon
              SvgPicture.asset(
                'assets/icons/location_pin_icon.svg',
                width: 20 * scale,
                height: 20 * scale,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFE74C3C),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12 * scale),
              // Address text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressLine1,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * scale,
                        color: const Color(0xFF19213D),
                      ),
                    ),
                    if (addressLine2.isNotEmpty)
                      Text(
                        addressLine2,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14 * scale,
                          color: const Color(0xFF19213D),
                        ),
                      ),
                    if (addressLine3.isNotEmpty)
                      Text(
                        addressLine3,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14 * scale,
                          color: const Color(0xFF19213D),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              // Map button
              GestureDetector(
                onTap: () async {
                  await openMapForQuery(context, fullAddress);
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/map.svg',
                      width: 24 * scale,
                      height: 24 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF19213D),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696969),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        'Map',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              // Edit button
              GestureDetector(
                onTap: () => _showEditAddressDialog(context),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Pen.svg',
                      width: 24 * scale,
                      height: 24 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF19213D),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696969),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformationCard(BuildContext context, double scale, {bool showSectionHeader = true}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionHeader) ...[
            Text(
              'Contact Information',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                color: const Color(0xFF19213D),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Enter your business mobile number',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12 * scale,
                color: const Color(0xFF6D758F),
              ),
            ),
            SizedBox(height: 16 * scale),
          ],

          // Phone input section
          Column(
            children: [
              Row(
                children: [
                  // Mobile icon
                  Icon(
                    Icons.phone_android,
                    size: 20 * scale,
                    color: const Color(0xFF19213D),
                  ),
                  SizedBox(width: 12 * scale),

                  // Country code selector
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
                          flagSize: 25 * scale,
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(
                              fontSize: 16 * scale, color: Colors.blueGrey),
                          bottomSheetHeight: 500 * scale,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0 * scale),
                            topRight: Radius.circular(20.0 * scale),
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
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flagEmoji,
                            style: TextStyle(fontSize: 20 * scale),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            _selectedCountry.phoneCode,
                            style: GoogleFonts.inter(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF19213D),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Container(
                            width: 20 * scale,
                            height: 20 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0097B2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 14 * scale,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),

                  // Phone number input
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: GoogleFonts.inter(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF19213D),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final phone = PartnerPhone(
                        phoneNumber: _phoneController.text.trim(),
                        countryCode: '+${_selectedCountry.phoneCode}',
                        isPrimary: true,
                      );
                      final success = await Provider.of<PartnerProvider>(context, listen: false)
                          .updatePhones([phone]);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Phone updated' : 'Failed to update phone'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/uil_edit.svg',
                      width: 24 * scale,
                      height: 24 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF19213D),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  GestureDetector(
                    onTap: () => _showAddContactDialog(context),
                    child: SvgPicture.asset(
                      'assets/icons/add.svg',
                      width: 24 * scale,
                      height: 24 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF19213D),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsCard(BuildContext context, double scale, {bool showSectionHeader = true}) {
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final provider = Provider.of<PartnerProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionHeader) ...[
            Text(
              'General Settings',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                color: const Color(0xFF19213D),
              ),
            ),
            SizedBox(height: 16 * scale),
          ],

          // Category selection row
          Row(
            children: [
              // Category icon
              SvgPicture.asset(
                'assets/icons/bxs_category-alt.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
              SizedBox(width: 12 * scale),

              // Category dropdown
              Expanded(
                child: InkWell(
                  onTap: () {
                    _setDashboardCategory(null);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dashboardCategory ?? _selectedCategory ?? 'Choose a category',
                            style: GoogleFonts.inter(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF19213D),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Container(
                          width: 20 * scale,
                          height: 20 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0097B2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 14 * scale,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Follow Us toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Thumbs up icon
                  SvgPicture.asset(
                    'assets/icons/mdi_like.svg',
                    width: 20 * scale,
                    height: 20 * scale,
                  ),
                  SizedBox(width: 12 * scale),

                  // Follow Me label
                  Text(
                    'Follow Me',
                    style: GoogleFonts.inter(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF19213D),
                    ),
                  ),
                ],
              ),

              // Toggle switch
              Switch(
                value: _followUs,
                onChanged: (value) {
                  setState(() {
                    _followUs = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF02A6C3),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Social links
          _buildFormField('Facebook URL', _facebookController, 'https://facebook.com/yourpage', w, fs),
          SizedBox(height: 10 * scale),
          _buildFormField('Instagram URL', _instagramController, 'https://instagram.com/yourpage', w, fs),
          SizedBox(height: 10 * scale),
          _buildFormField('WhatsApp', _whatsappController, 'e.g. +92-300-1234567', w, fs),
          SizedBox(height: 10 * scale),
          _buildFormField('Website', _websiteController, 'https://yourbusiness.com', w, fs),
          SizedBox(height: 12 * scale),

          _buildSubmitButton('Save Settings', () async {
            final data = <String, dynamic>{
              'followUsEnabled': _followUs,
              'facebookUrl': _facebookController.text.trim(),
              'instagramUrl': _instagramController.text.trim(),
              'whatsapp': _whatsappController.text.trim(),
              'websiteUrl': _websiteController.text.trim(),
            };
            final ok = await provider.updateProfile(data);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Settings saved' : (provider.error ?? 'Failed to save settings'))),
              );
            }
          }, w, fs, provider.isSaving),
          SizedBox(height: 16 * scale),

          // Business profile rating row
          Row(
            children: [
              // Chat/review icon
              SvgPicture.asset(
                'assets/icons/ratting.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
              SizedBox(width: 12 * scale),

              // Business profile rating label
              Expanded(
                child: Text(
                  'Business profile rating',
                  style: GoogleFonts.inter(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF19213D),
                  ),
                ),
              ),

              // Rating value
              Text(
                (Provider.of<PartnerProvider>(context, listen: false).partner?.rating ?? 0).toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF19213D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUploadCard(BuildContext context, double scale) {
    // Figma dimensions: 390 width base
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final pp = Provider.of<PartnerProvider>(context);
    final serviceProviders = pp.serviceProviders;
    final selectedProviderId = _galleryServiceProviderId;
    final selectedProviderMedia = selectedProviderId == null
        ? const <PartnerMediaModel>[]
        : pp.mediaForProvider(selectedProviderId);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(w(10)),
          topRight: Radius.circular(w(10)),
        ),
      ),
      child: Column(
        children: [
          // Header Section - Upload a file
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(20)),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFCBD0DC), width: 2),
              ),
            ),
            child: Row(
              children: [
                // Cloud icon with circular border
                Container(
                  width: w(50),
                  height: w(50),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD0DC), width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: w(22),
                      color: const Color(0xFFCBD0DC),
                    ),
                  ),
                ),
                SizedBox(width: w(10)),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gallery Manager',
                        style: GoogleFonts.inter(
                          fontSize: fs(15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Upload photos and videos for your selected service provider',
                        style: GoogleFonts.inter(
                          fontSize: fs(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA9ACB4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File upload dismissed'), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Container(
                    width: w(25),
                    height: w(50),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close,
                      size: w(15),
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: w(10)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(20)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w(10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(w(8)),
                border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedProviderId,
                  hint: Text(
                    'Select service provider',
                    style: GoogleFonts.inter(
                      fontSize: fs(13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF54575C),
                    ),
                  ),
                  items: serviceProviders
                      .map(
                        (sp) => DropdownMenuItem<String>(
                          value: sp.id,
                          child: Text(
                            sp.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: fs(13),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    setState(() {
                      _galleryServiceProviderId = value;
                    });
                    if (value != null && value.isNotEmpty) {
                      await Provider.of<PartnerProvider>(context, listen: false)
                          .fetchServiceProviderMedia(value, force: true);
                    }
                  },
                ),
              ),
            ),
          ),

          // Media upload area with dashed border
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(20)),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: const Color(0xFFCBD0DC),
                strokeWidth: 2,
                borderRadius: w(15),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(20)),
                child: Column(
                  children: [
                    // Photo and Video buttons row
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: w(10),
                      runSpacing: w(10),
                      children: [
                        // Photo button with black dashed border
                        GestureDetector(
                          onTap: () => _pickAndUploadProviderMedia(isVideo: false),
                          child: CustomPaint(
                            painter: DashedBorderPainter(
                              color: Colors.black,
                              strokeWidth: 1,
                              borderRadius: w(5),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w(22), vertical: w(17)),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: w(25),
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Photo',
                                    style: GoogleFonts.inter(
                                      fontSize: fs(11),
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Video button with gray dashed border
                        GestureDetector(
                          onTap: () => _pickAndUploadProviderMedia(isVideo: true),
                          child: CustomPaint(
                            painter: DashedBorderPainter(
                              color: const Color(0xFFBCBCBC),
                              strokeWidth: 1,
                              borderRadius: w(5),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w(22), vertical: w(17)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_outlined,
                                    size: w(25),
                                    color: const Color(0xFFBCBCBC),
                                  ),
                                  Text(
                                    'Video',
                                    style: GoogleFonts.inter(
                                      fontSize: fs(11),
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFBCBCBC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: w(10)),
                    // Choose file text
                    Text(
                      'Choose a file or drag and drop it here',
                      style: GoogleFonts.inter(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: w(5)),
                    // Format text
                    Text(
                      'JPEG, PNG, and MP4 format up to 50MB',
                      style: GoogleFonts.inter(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA9ACB4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: w(10)),
                    // Browse button
                    GestureDetector(
                      onTap: () => _pickAndUploadProviderMedia(isVideo: false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: w(20), vertical: w(5)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w(8)),
                          border: Border.all(color: const Color(0xFFA9ACB4), width: 1),
                        ),
                        child: Text(
                          'Browse',
                          style: GoogleFonts.inter(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF54575C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: w(10)),

          if (selectedProviderId == null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w(20), vertical: w(4)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select a service provider to manage gallery',
                  style: GoogleFonts.inter(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA9ACB4),
                  ),
                ),
              ),
            ),

          if (selectedProviderId != null && selectedProviderMedia.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w(20), vertical: w(4)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No media uploaded',
                  style: GoogleFonts.inter(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA9ACB4),
                  ),
                ),
              ),
            ),

          // Dynamic file upload cards from backend
          ...selectedProviderMedia.map((mediaItem) {
            return Padding(
              padding: EdgeInsets.only(
                left: w(20),
                right: w(20),
                bottom: w(10),
              ),
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w(10)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1F7),
                    borderRadius: BorderRadius.circular(w(15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Thumbnail image
                          GestureDetector(
                            onTap: () => _openMediaUrl(mediaItem.fileUrl),
                            child: _buildMediaThumb(
                              fileUrl: mediaItem.fileUrl,
                              mediaType: mediaItem.mediaType,
                              size: w(45),
                            ),
                          ),
                          SizedBox(width: w(15)),
                          // File info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem.fileName ?? 'Media file',
                                  style: GoogleFonts.inter(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: w(5)),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        mediaItem.fileSizeKb != null
                                            ? '${mediaItem.fileSizeKb} KB'
                                            : mediaItem.mediaType,
                                        style: GoogleFonts.inter(
                                          fontSize: fs(11),
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFA9ACB4),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: w(5)),
                                    Container(
                                      width: w(5),
                                      height: w(5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFA9ACB4),
                                      ),
                                    ),
                                    SizedBox(width: w(5)),
                                    Icon(
                                      Icons.check_circle,
                                      size: w(15),
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    SizedBox(width: w(5)),
                                    Flexible(
                                      child: Text(
                                        'Uploaded',
                                        style: GoogleFonts.inter(
                                          fontSize: fs(11),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF292D32),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          GestureDetector(
                            onTap: () {
                              if (selectedProviderId == null) return;
                              _deleteServiceProviderMedia(selectedProviderId, mediaItem.id);
                            },
                            child: Icon(
                              Icons.delete_outline,
                              size: w(20),
                              color: const Color(0xFF292D32),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: w(15)),
                      // Progress bar (always complete for uploaded files)
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: w(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD0DC),
                              borderRadius: BorderRadius.circular(w(100)),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 1.0,
                            child: Container(
                              height: w(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF375EF9),
                                borderRadius: BorderRadius.circular(w(100)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            );
          }),

          // Guidelines text
          Padding(
            padding: EdgeInsets.symmetric(vertical: w(5), horizontal: w(20)),
            child: Text(
              'Please carefully follow the above guidelines when uploading a file',
              style: GoogleFonts.inter(
                fontSize: fs(11),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E8E8E),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: w(10)),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ My Services Card Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildMyServicesCard(BuildContext context, double scale) {
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final provider = Provider.of<PartnerProvider>(context);
    final items = provider.serviceProviders;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(15)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFCBD0DC), width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.build_outlined, size: w(22), color: const Color(0xFF0097B2)),
                SizedBox(width: w(10)),
                Text(
                  'My Services',
                  style: GoogleFonts.inter(fontSize: fs(15), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: GoogleFonts.inter(fontSize: fs(13), color: const Color(0xFF6D758F)),
                ),
              ],
            ),
          ),
          // Form
          Padding(
            padding: EdgeInsets.all(w(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField('Service Name *', _spNameController, 'e.g. Ahmed Plumbing', w, fs),
                SizedBox(height: w(10)),
                // Service image upload
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Image',
                      style: GoogleFonts.sourceSans3(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09101D).withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: w(4)),
                    Row(
                      children: [
                        if (_bizImageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(w(8)),
                            child: Image.network(
                              _bizImageUrl!,
                              width: w(44),
                              height: w(44),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: w(44),
                                height: w(44),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF2),
                                  borderRadius: BorderRadius.circular(w(8)),
                                ),
                                child: Icon(Icons.image, size: w(20), color: const Color(0xFF7A8594)),
                              ),
                            ),
                          ),
                          SizedBox(width: w(8)),
                        ],
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(12)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w(8)),
                              border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
                            ),
                            child: Text(
                              _spImageUrl != null ? 'Image uploaded' : 'No image selected',
                              style: GoogleFonts.sourceSans3(
                                fontSize: fs(14),
                                color: const Color(0xFF09101D).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w(10)),
                        SizedBox(
                          height: w(44),
                          child: ElevatedButton(
                            onPressed: _pickServiceProviderImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0097B2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: w(14), vertical: 0),
                              minimumSize: Size(w(80), w(44)),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w(8))),
                            ),
                            child: Text(
                              'Upload',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: w(10)),
                _buildFormField('Phone', _spPhoneController, 'e.g. 0300-1234567', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('WhatsApp', _spWhatsappController, 'e.g. +92-300-1234567', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Address', _spAddressController, 'e.g. DHA Phase 5, Lahore', w, fs),
                SizedBox(height: w(10)),
                // Service Type dropdown
                _buildDropdown(
                  label: 'Service Type *',
                  value: _spServiceType,
                  items: const ['LAUNDRY', 'PLUMBER', 'ELECTRICIAN', 'PAINTER', 'CARPENTER', 'BARBER', 'MAID', 'SALON', 'REAL_ESTATE', 'DOCTOR', 'WATER', 'GAS'],
                  itemLabel: (v) => v[0] + v.substring(1).toLowerCase().replaceAll('_', ' '),
                  onChanged: (v) async {
                    setState(() {
                      _spServiceType = v;
                      if (v != 'DOCTOR') {
                        _spDoctorIdController.clear();
                        _spExperienceYearsController.clear();
                        _spHospitalNameController.clear();
                        _spConsultationChargeController.clear();
                        _spPatientsCountController.clear();
                      }
                    });
                    await _loadSkillSuggestionsForType(v);
                  },
                  w: w, fs: fs,
                ),
                SizedBox(height: w(10)),
                Text(
                  'Services Offered',
                  style: GoogleFonts.sourceSans3(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF09101D).withOpacity(0.8),
                  ),
                ),
                SizedBox(height: w(4)),
                if (_spSuggestedSkills.isNotEmpty) ...[
                  Wrap(
                    spacing: w(8),
                    runSpacing: w(8),
                    children: _spSuggestedSkills.map((skill) {
                      final selected = _spSelectedSkills.any(
                        (s) => s.toLowerCase() == skill.toLowerCase(),
                      );
                      return GestureDetector(
                        onTap: () {
                          if (selected) {
                            _removeSkillTag(skill);
                          } else {
                            _addSkillTag(skill);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF0097B2).withOpacity(0.12) : const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(w(20)),
                            border: Border.all(
                              color: selected ? const Color(0xFF0097B2) : const Color(0xFFE2E2E2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                _serviceTypeIcons[_spServiceType ?? ''] ?? 'assets/icons/jobs.svg',
                                width: w(14),
                                height: w(14),
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF4C4C4C),
                                  BlendMode.srcIn,
                                ),
                                placeholderBuilder: (_) => Icon(
                                  Icons.miscellaneous_services,
                                  size: w(14),
                                  color: const Color(0xFF4C4C4C),
                                ),
                              ),
                              SizedBox(width: w(5)),
                              Text(
                                skill,
                                style: GoogleFonts.inter(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4C4C4C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: w(8)),
                ],
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: TextField(
                    controller: _spSkillInputController,
                    focusNode: _spSkillFocusNode,
                    onSubmitted: _addSkillTag,
                    style: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D)),
                    decoration: InputDecoration(
                      hintText: 'Type a service and press Enter',
                      hintStyle: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D).withOpacity(0.3)),
                      contentPadding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(10)),
                      suffixIcon: IconButton(
                        onPressed: () => _addSkillTag(_spSkillInputController.text),
                        icon: Icon(Icons.add, size: w(18), color: const Color(0xFF0097B2)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
                      ),
                    ),
                  ),
                ),
                if (_spSelectedSkills.isNotEmpty) ...[
                  SizedBox(height: w(8)),
                  Wrap(
                    spacing: w(8),
                    runSpacing: w(8),
                    children: _spSelectedSkills.map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(w(20)),
                          border: Border.all(color: const Color(0xFFE2E2E2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: GoogleFonts.inter(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4C4C4C),
                              ),
                            ),
                            SizedBox(width: w(6)),
                            GestureDetector(
                              onTap: () => _removeSkillTag(skill),
                              child: Icon(Icons.close, size: w(14), color: const Color(0xFF6D758F)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: w(10)),
                _buildFormField('City', _spCityController, 'Lahore', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Service Charge (PKR)', _spChargeController, '0', w, fs, isNumber: true),
                SizedBox(height: w(12)),
                _buildFormField('Jobs Completed', _spJobsCompletedController, '0', w, fs, isNumber: true),
                SizedBox(height: w(10)),
                _buildFormField('Working Since', _spWorkingSinceController, 'e.g. 2018', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Response Time', _spResponseTimeController, 'e.g. Within 1 hour', w, fs),
                SizedBox(height: w(10)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(w(10)),
                    border: Border.all(color: const Color(0xFFE3E7EE), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Professional Profile',
                              style: GoogleFonts.inter(
                                fontSize: fs(13),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF19213D),
                              ),
                            ),
                          ),
                          Switch(
                            value: _spProfessionalProfileEnabled,
                            onChanged: (value) {
                              setState(() {
                                _spProfessionalProfileEnabled = value;
                                if (!value) {
                                  _spFollowEnabled = false;
                                }
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF02A6C3),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Enable Following',
                              style: GoogleFonts.inter(
                                fontSize: fs(13),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF19213D),
                              ),
                            ),
                          ),
                          Switch(
                            value: _spProfessionalProfileEnabled && _spFollowEnabled,
                            onChanged: _spProfessionalProfileEnabled
                                ? (value) {
                                    setState(() {
                                      _spFollowEnabled = value;
                                    });
                                  }
                                : null,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF02A6C3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(10)),
                _buildFormField(
                  'Vendor ID',
                  _spVendorIdController,
                  'Auto-generated by system',
                  w,
                  fs,
                  enabled: true,
                  readOnly: true,
                ),
                if (_spServiceType == 'DOCTOR') ...[
                  SizedBox(height: w(10)),
                  _buildFormField('Doctor ID', _spDoctorIdController, 'e.g. D-1234', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('Experience Years', _spExperienceYearsController, '0', w, fs, isNumber: true),
                  SizedBox(height: w(10)),
                  _buildFormField('Hospital Name', _spHospitalNameController, 'e.g. City Hospital', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('Consultation Charge (PKR)', _spConsultationChargeController, '0', w, fs, isNumber: true),
                  SizedBox(height: w(10)),
                  _buildFormField('Patients Count', _spPatientsCountController, '0', w, fs, isNumber: true),
                ],
                SizedBox(height: w(12)),
                _buildSubmitButton('Add Service', () async {
                  if (_spNameController.text.trim().isEmpty || _spServiceType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and service type are required')),
                    );
                    return;
                  }
                  String? categoryId = _resolveCategoryIdForServiceType(_spServiceType!);
                  final data = {
                    'name': _spNameController.text.trim(),
                    'serviceType': _spServiceType,
                    if (categoryId != null) 'categoryId': categoryId,
                    if (_spSelectedSkills.isNotEmpty) 'skills': _spSelectedSkills,
                    if (_spImageUrl != null) 'imageUrl': _spImageUrl,
                    if (_spPhoneController.text.trim().isNotEmpty) 'phone': _spPhoneController.text.trim(),
                    if (_spWhatsappController.text.trim().isNotEmpty)
                      'whatsapp': _spWhatsappController.text.trim(),
                    if (_spAddressController.text.trim().isNotEmpty) 'address': _spAddressController.text.trim(),
                    'city': _spCityController.text.trim().isNotEmpty ? _spCityController.text.trim() : 'Lahore',
                    if (_spChargeController.text.trim().isNotEmpty)
                      'serviceCharge': double.tryParse(_spChargeController.text.trim()) ?? 0,
                    if (_spJobsCompletedController.text.trim().isNotEmpty)
                      'jobsCompleted': int.tryParse(_spJobsCompletedController.text.trim()) ?? 0,
                    if (_spWorkingSinceController.text.trim().isNotEmpty)
                      'workingSince': _spWorkingSinceController.text.trim(),
                    if (_spResponseTimeController.text.trim().isNotEmpty)
                      'responseTime': _spResponseTimeController.text.trim(),
                    'isProfessionalProfileEnabled': _spProfessionalProfileEnabled,
                    'isFollowEnabled':
                        _spProfessionalProfileEnabled && _spFollowEnabled,
                    if (_spServiceType == 'DOCTOR' && _spDoctorIdController.text.trim().isNotEmpty)
                      'doctorId': _spDoctorIdController.text.trim(),
                    if (_spServiceType == 'DOCTOR' && _spExperienceYearsController.text.trim().isNotEmpty)
                      'experienceYears': int.tryParse(_spExperienceYearsController.text.trim()) ?? 0,
                    if (_spServiceType == 'DOCTOR' && _spHospitalNameController.text.trim().isNotEmpty)
                      'hospitalName': _spHospitalNameController.text.trim(),
                    if (_spServiceType == 'DOCTOR' && _spConsultationChargeController.text.trim().isNotEmpty)
                      'consultationCharge': double.tryParse(_spConsultationChargeController.text.trim()) ?? 0,
                    if (_spServiceType == 'DOCTOR' && _spPatientsCountController.text.trim().isNotEmpty)
                      'patientsCount': int.tryParse(_spPatientsCountController.text.trim()) ?? 0,
                  };
                  final bool ok;
                  if (_editingServiceProviderId != null) {
                    ok = await provider.updateServiceProvider(_editingServiceProviderId!, data);
                  } else {
                    ok = await provider.createServiceProvider(data);
                  }
                  if (ok && mounted) {
                    await provider.fetchServiceProviders();
                    final wasEditing = _editingServiceProviderId != null;
                    _clearServiceProviderForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasEditing
                              ? 'Service provider updated and sent for approval.'
                              : 'Service provider created!',
                        ),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Failed to create service provider'),
                      ),
                    );
                  }
                }, w, fs, provider.isSaving),
              ],
            ),
          ),
          // List of existing service providers
          if (items.isNotEmpty)
            ...items.map((sp) => _buildListTile(
              title: sp.name,
              subtitle: '${sp.serviceType} Ã‚Â· ${sp.city ?? 'Lahore'}',
              onTap: () => _startEditServiceProvider(sp),
              onDelete: () => provider.deleteServiceProvider(sp.id),
              w: w, fs: fs,
            )),
          SizedBox(height: w(10)),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ My Businesses Card Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildMyBusinessesCard(BuildContext context, double scale) {
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final provider = Provider.of<PartnerProvider>(context);
    final items = provider.businesses;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(15)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFCBD0DC), width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.store_outlined, size: w(22), color: const Color(0xFF0097B2)),
                SizedBox(width: w(10)),
                Text(
                  'My Businesses',
                  style: GoogleFonts.inter(fontSize: fs(15), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: GoogleFonts.inter(fontSize: fs(13), color: const Color(0xFF6D758F)),
                ),
              ],
            ),
          ),
          // Form
          Padding(
            padding: EdgeInsets.all(w(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField('Business Name *', _bizNameController, 'e.g. Ali Grocery Store', w, fs),
                SizedBox(height: w(10)),
                // Business image upload
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Image',
                      style: GoogleFonts.sourceSans3(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09101D).withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: w(4)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(12)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w(8)),
                              border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
                            ),
                            child: Text(
                              _bizImageUrl != null
                                  ? (_editingBusinessId != null
                                      ? 'Image uploaded (auto-saved)'
                                      : 'Image uploaded (draft)')
                                  : 'No image selected',
                              style: GoogleFonts.sourceSans3(
                                fontSize: fs(14),
                                color: const Color(0xFF09101D).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w(10)),
                        SizedBox(
                          height: w(44),
                          child: ElevatedButton(
                            onPressed: _pickBusinessImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0097B2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: w(14), vertical: 0),
                              minimumSize: Size(w(80), w(44)),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w(8))),
                            ),
                            child: Text(
                              'Upload',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: w(10)),
                _buildDropdown(
                  label: 'Category *',
                  value: _bizCategory,
                  items: const ['STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF'],
                  itemLabel: (v) => v[0] + v.substring(1).toLowerCase().replaceAll('_', ' '),
                  onChanged: (v) => setState(() {
                    final pp = Provider.of<PartnerProvider>(context, listen: false);
                    final agents = _realEstateAgentsAny(pp);
                    _bizCategory = v;
                    _bizSelectedServices = _businessServiceOptionsForCategory(v)
                        .take(4)
                        .map((e) => e.label)
                        .toList();
                    if ((v ?? '').toUpperCase() == 'REAL_ESTATE') {
                      Future.microtask(() => pp.fetchServiceProviders());
                      _bizPropertyType ??= 'House';
                      _bizPropertyPurpose ??= 'RENTAL';
                      _bizPropertyStatus ??= 'FEATURED';
                      if (agents.isEmpty) {
                        _bizRealEstateAgentId = null;
                      } else if (_bizRealEstateAgentId == null ||
                          !agents.any((a) => a.id == _bizRealEstateAgentId)) {
                        _bizRealEstateAgentId = agents.first.id;
                      }
                    } else {
                      _bizPropertyType = null;
                      _bizPropertyPurpose = null;
                      _bizPropertyStatus = null;
                      _bizRealEstateAgentId = null;
                    }
                  }),
                  w: w, fs: fs,
                ),
                SizedBox(height: w(10)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(8)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEEF2),
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: w(16), color: const Color(0xFF858C94)),
                      SizedBox(width: w(6)),
                      Expanded(
                        child: Text(
                          'Timings and working days are managed from the header section.',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF394452),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(10)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(w(10)),
                    border: Border.all(color: const Color(0xFFE3E7EE), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enable Following',
                          style: GoogleFonts.inter(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF19213D),
                          ),
                        ),
                      ),
                      Switch(
                        value: _bizFollowEnabled,
                        onChanged: (value) {
                          setState(() {
                            _bizFollowEnabled = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF02A6C3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(10)),
                if (_isRealEstateCategorySelected)
                  _buildRealEstateBusinessFields(w, fs)
                else ...[
                  _buildFormField('Location', _bizLocationController, 'e.g. DHA Phase 5, Lahore', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('Phone', _bizPhoneController, 'e.g. 0300-1234567', w, fs),
                  SizedBox(height: w(10)),
                  _buildServicesOfferedIconSection(
                    title: 'Services Offered',
                    options: _businessServiceOptionsForCategory(_bizCategory),
                    selected: _bizSelectedServices,
                    onToggle: (label) {
                      setState(() {
                        if (_bizSelectedServices.any((s) => s.toLowerCase() == label.toLowerCase())) {
                          _bizSelectedServices = _bizSelectedServices
                              .where((s) => s.toLowerCase() != label.toLowerCase())
                              .toList();
                        } else {
                          _bizSelectedServices = [..._bizSelectedServices, label];
                        }
                      });
                    },
                    w: w,
                    fs: fs,
                  ),
                  if (_bizCategory != null) ...[
                    SizedBox(height: w(10)),
                    _buildFormField(
                      'Additional Services (comma separated)',
                      _bizServicesController,
                      'Delivery, Pickup, Online Payment',
                      w,
                      fs,
                    ),
                  ],
                  SizedBox(height: w(10)),
                  _buildFormField('Description', _bizDescController, 'Brief description...', w, fs, maxLines: 2),
                  SizedBox(height: w(12)),
                  _buildFormField('Facebook URL', _bizFacebookController, 'https://facebook.com/yourpage', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('Instagram URL', _bizInstagramController, 'https://instagram.com/yourpage', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('WhatsApp', _bizWhatsappController, 'e.g. +92-300-1234567', w, fs),
                  SizedBox(height: w(10)),
                  _buildFormField('Website', _bizWebsiteController, 'https://yourbusiness.com', w, fs),
                ],
                SizedBox(height: w(12)),
                _buildSubmitButton(_editingBusinessId != null ? 'Update Business' : 'Add Business', () async {
                  final data = _buildBusinessPayload();
                  if (data == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and category are required')),
                    );
                    return;
                  }
                  if (data['_validationError'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['_validationError'].toString())),
                    );
                    return;
                  }
                  final isRealEstate = (data['category']?.toString().toUpperCase() ?? '') == 'REAL_ESTATE';
                  final bool ok;
                  final bool isEditing = _editingBusinessId != null;
                  if (isEditing) {
                    ok = await provider.updateBusiness(_editingBusinessId!, data);
                  } else {
                    ok = await provider.createBusiness(data);
                  }
                  if (ok && mounted) {
                    await provider.fetchBusinesses();
                    _clearBusinessForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? (isRealEstate
                                  ? 'Property updated and sent for approval.'
                                  : 'Business updated and sent for approval.')
                              : (isRealEstate ? 'Property created!' : 'Business created!'),
                        ),
                      ),
                    );
                  }
                }, w, fs, provider.isSaving),
              ],
            ),
          ),
          // List
          if (items.isNotEmpty)
            ...items.map((biz) => _buildBusinessListTile(biz, w, fs)),
          SizedBox(height: w(10)),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ My Amenities Card Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  Widget _buildRealEstateBusinessFields(
    double Function(double) w,
    double Function(double) fs,
  ) {
    final pp = Provider.of<PartnerProvider>(context, listen: true);
    final agents = _realEstateAgentsAny(pp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (agents.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(w(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(w(8)),
              border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Real Estate Agent profile found.',
                  style: GoogleFonts.inter(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF19213D),
                  ),
                ),
                SizedBox(height: w(6)),
                Text(
                  'Create an agent profile first, then come back to add property.',
                  style: GoogleFonts.inter(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6D758F),
                  ),
                ),
                SizedBox(height: w(8)),
                Row(
                  children: [
                    TextButton(
                      onPressed: _openRealEstateAgentSetup,
                      child: const Text('Create Agent Profile'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Provider.of<PartnerProvider>(context, listen: false).fetchServiceProviders(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: w(10)),
        ],
        Text(
          'Property ID',
          style: GoogleFonts.sourceSans3(
            fontSize: fs(14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF09101D).withOpacity(0.8),
          ),
        ),
        SizedBox(height: w(4)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(12)),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(w(8)),
            border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
          ),
          child: Text(
            _editingBusinessId?.startsWith('property:') == true
                ? _editingBusinessId!.substring('property:'.length)
                : 'Auto-generated on save',
            style: GoogleFonts.sourceSans3(
              fontSize: fs(14),
              color: const Color(0xFF09101D).withOpacity(0.7),
            ),
          ),
        ),
        SizedBox(height: w(10)),
        _buildDropdown(
          label: 'Agent Profile *',
          value: _bizRealEstateAgentId,
          items: agents.map((a) => a.id).toList(),
          itemLabel: (id) {
            final a = agents.firstWhere((e) => e.id == id);
            return _isCompleteRealEstateAgent(a)
                ? a.name
                : '${a.name} (Complete profile required)';
          },
          onChanged: (v) => setState(() => _bizRealEstateAgentId = v),
          w: w,
          fs: fs,
        ),
        SizedBox(height: w(10)),
        _buildDropdown(
          label: 'Property Status *',
          value: _bizPropertyStatus,
          items: _propertyStatuses,
          itemLabel: (v) => v
              .toLowerCase()
              .split('_')
              .map((e) => e.isEmpty ? e : e[0].toUpperCase() + e.substring(1))
              .join(' '),
          onChanged: (v) => setState(() => _bizPropertyStatus = v),
          w: w,
          fs: fs,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'Property Location *',
          _bizLocationController,
          'e.g. DHA Phase 5, Lahore',
          w,
          fs,
        ),
        SizedBox(height: w(10)),
        _buildDropdown(
          label: 'Property Type *',
          value: _bizPropertyType,
          items: _propertyListingTypes,
          itemLabel: (v) => v,
          onChanged: (v) => setState(() => _bizPropertyType = v),
          w: w,
          fs: fs,
        ),
        SizedBox(height: w(10)),
        _buildDropdown(
          label: 'Purpose *',
          value: _bizPropertyPurpose,
          items: _propertyPurposes,
          itemLabel: (v) => v == 'SALE' ? 'Sale' : 'Rental',
          onChanged: (v) => setState(() => _bizPropertyPurpose = v),
          w: w,
          fs: fs,
        ),
        SizedBox(height: w(10)),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                'Price (PKR) *',
                _bizPriceController,
                'e.g. 15,000,000',
                w,
                fs,
                isNumber: true,
              ),
            ),
            SizedBox(width: w(10)),
            Expanded(
              child: _buildFormField(
                'Marla / Area',
                _bizSqftController,
                'e.g. 1200 sqft',
                w,
                fs,
                isNumber: true,
              ),
            ),
          ],
        ),
        SizedBox(height: w(10)),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                'Beds',
                _bizBedsController,
                '3',
                w,
                fs,
                isNumber: true,
              ),
            ),
            SizedBox(width: w(10)),
            Expanded(
              child: _buildFormField(
                'Baths',
                _bizBathsController,
                '2',
                w,
                fs,
                isNumber: true,
              ),
            ),
            SizedBox(width: w(10)),
            Expanded(
              child: _buildFormField(
                'Kitchen',
                _bizKitchenController,
                '1',
                w,
                fs,
                isNumber: true,
              ),
            ),
          ],
        ),
        SizedBox(height: w(10)),
        _buildServicesOfferedIconSection(
          title: 'Property Highlights',
          options: _businessServiceOptionsForCategory('REAL_ESTATE'),
          selected: _bizSelectedServices,
          onToggle: (label) {
            setState(() {
              if (_bizSelectedServices.any((s) => s.toLowerCase() == label.toLowerCase())) {
                _bizSelectedServices = _bizSelectedServices
                    .where((s) => s.toLowerCase() != label.toLowerCase())
                    .toList();
              } else {
                _bizSelectedServices = [..._bizSelectedServices, label];
              }
            });
          },
          w: w,
          fs: fs,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'Additional Highlights (comma separated)',
          _bizServicesController,
          'Corner plot, Parking, West-open',
          w,
          fs,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'Description',
          _bizDescController,
          'Brief property details...',
          w,
          fs,
          maxLines: 3,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'Phone',
          _bizPhoneController,
          'e.g. 0300-1234567',
          w,
          fs,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'WhatsApp',
          _bizWhatsappController,
          'e.g. +92-300-1234567',
          w,
          fs,
        ),
        SizedBox(height: w(10)),
        _buildFormField(
          'Website',
          _bizWebsiteController,
          'https://yourpropertysite.com',
          w,
          fs,
        ),
      ],
    );
  }
  Widget _buildMyAmenitiesCard(BuildContext context, double scale) {
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final provider = Provider.of<PartnerProvider>(context);
    final items = provider.amenities;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(15)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFCBD0DC), width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city_outlined, size: w(22), color: const Color(0xFF0097B2)),
                SizedBox(width: w(10)),
                Text(
                  'My Amenities',
                  style: GoogleFonts.inter(fontSize: fs(15), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: GoogleFonts.inter(fontSize: fs(13), color: const Color(0xFF6D758F)),
                ),
              ],
            ),
          ),
          // Form
          Padding(
            padding: EdgeInsets.all(w(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField('Amenity Name *', _amenityNameController, 'e.g. Masjid Al-Rehman', w, fs),
                SizedBox(height: w(10)),
                // Amenity image upload
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenity Image',
                      style: GoogleFonts.sourceSans3(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09101D).withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: w(4)),
                    Row(
                      children: [
                        if (_amenityImageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(w(8)),
                            child: Image.network(
                              _amenityImageUrl!,
                              width: w(44),
                              height: w(44),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: w(44),
                                height: w(44),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF2),
                                  borderRadius: BorderRadius.circular(w(8)),
                                ),
                                child: Icon(Icons.image, size: w(20), color: const Color(0xFF7A8594)),
                              ),
                            ),
                          ),
                          SizedBox(width: w(8)),
                        ],
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(12)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w(8)),
                              border: Border.all(color: const Color(0xFFCBD0DC), width: 1),
                            ),
                            child: Text(
                              _amenityImageUrl != null
                                  ? (_editingAmenityId != null
                                      ? 'Image uploaded (auto-saved)'
                                      : 'Image uploaded (draft)')
                                  : 'No image selected',
                              style: GoogleFonts.sourceSans3(
                                fontSize: fs(14),
                                color: const Color(0xFF09101D).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w(10)),
                        SizedBox(
                          height: w(44),
                          child: ElevatedButton(
                            onPressed: _pickAmenityImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0097B2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: w(14), vertical: 0),
                              minimumSize: Size(w(80), w(44)),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w(8))),
                            ),
                            child: Text(
                              'Upload',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: w(10)),
                _buildDropdown(
                  label: 'Amenity Type *',
                  value: _amenityType,
                  items: const ['MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE', 'ADMIN'],
                  itemLabel: (v) => v[0] + v.substring(1).toLowerCase(),
                  onChanged: (v) => setState(() {
                    _amenityType = v;
                    _amenitySelectedServices = _amenityServiceOptionsForType(v)
                        .take(4)
                        .map((e) => e.label)
                        .toList();
                  }),
                  w: w, fs: fs,
                ),
                SizedBox(height: w(10)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(8)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEEF2),
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: w(16), color: const Color(0xFF858C94)),
                      SizedBox(width: w(6)),
                      Expanded(
                        child: Text(
                          'Timings and working days are managed from the header section.',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF394452),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(10)),
                _buildFormField('Location', _amenityLocationController, 'e.g. Gulberg III, Lahore', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Phone', _amenityPhoneController, 'e.g. 042-35761234', w, fs),
                SizedBox(height: w(10)),
                _buildServicesOfferedIconSection(
                  title: 'Services Offered',
                  options: _amenityServiceOptionsForType(_amenityType),
                  selected: _amenitySelectedServices,
                  onToggle: (label) {
                    setState(() {
                      if (_amenitySelectedServices.any((s) => s.toLowerCase() == label.toLowerCase())) {
                        _amenitySelectedServices = _amenitySelectedServices
                            .where((s) => s.toLowerCase() != label.toLowerCase())
                            .toList();
                      } else {
                        _amenitySelectedServices = [..._amenitySelectedServices, label];
                      }
                    });
                  },
                  w: w,
                  fs: fs,
                ),
                if (_amenityType != null) ...[
                  SizedBox(height: w(10)),
                  _buildFormField(
                    'Additional Services (comma separated)',
                    _amenityServicesController,
                    'Parking, Wheelchair Access',
                    w,
                    fs,
                  ),
                ],
                SizedBox(height: w(10)),
                _buildFormField('Description', _amenityDescController, 'Brief description...', w, fs, maxLines: 2),
                SizedBox(height: w(12)),
                _buildFormField('Facebook URL', _amenityFacebookController, 'https://facebook.com/yourpage', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Instagram URL', _amenityInstagramController, 'https://instagram.com/yourpage', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('WhatsApp', _amenityWhatsappController, 'e.g. +92-300-1234567', w, fs),
                SizedBox(height: w(10)),
                _buildFormField('Website', _amenityWebsiteController, 'https://youramenity.com', w, fs),
                SizedBox(height: w(12)),
                _buildSubmitButton(_editingAmenityId != null ? 'Update Amenity' : 'Add Amenity', () async {
                  final data = _buildAmenityPayload();
                  if (data == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and amenity type are required')),
                    );
                    return;
                  }
                  if (data['_validationError'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['_validationError'].toString())),
                    );
                    return;
                  }
                  final bool ok;
                  final bool isEditing = _editingAmenityId != null;
                  if (isEditing) {
                    ok = await provider.updateAmenity(_editingAmenityId!, data);
                  } else {
                    ok = await provider.createAmenity(data);
                  }
                  if (ok && mounted) {
                    await provider.fetchAmenities();
                    _clearAmenityForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Amenity updated and sent for approval.'
                              : 'Amenity created!',
                        ),
                      ),
                    );
                  }
                }, w, fs, provider.isSaving),
              ],
            ),
          ),
          // List
          if (items.isNotEmpty)
            ...items.map((a) => _buildAmenityListTile(a, w, fs)),
          SizedBox(height: w(10)),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Shared form helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
    double Function(double) w,
    double Function(double) fs, {
    bool isNumber = false,
    int maxLines = 1,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: fs(14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF09101D).withOpacity(0.8),
          ),
        ),
        SizedBox(height: w(4)),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w(8)),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly || !enabled,
            enableInteractiveSelection: enabled && !readOnly,
            showCursor: enabled && !readOnly,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : (label.toLowerCase().contains('phone') ||
                        label.toLowerCase().contains('whatsapp'))
                    ? TextInputType.phone
                    : TextInputType.text,
            maxLines: maxLines,
            style: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D).withOpacity(0.3)),
              contentPadding: EdgeInsets.symmetric(horizontal: w(12), vertical: w(10)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w(8)),
                borderSide: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesOfferedIconSection({
    required String title,
    required List<_ServiceVisualOption> options,
    required List<String> selected,
    required ValueChanged<String> onToggle,
    required double Function(double) w,
    required double Function(double) fs,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.sourceSans3(
            fontSize: fs(14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF09101D).withOpacity(0.8),
          ),
        ),
        SizedBox(height: w(8)),
        Wrap(
          spacing: w(8),
          runSpacing: w(8),
          children: options.map((opt) {
            final isSelected = selected.any((s) => s.toLowerCase() == opt.label.toLowerCase());
            return GestureDetector(
              onTap: () => onToggle(opt.label),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(8)),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0097B2).withOpacity(0.12) : const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(w(10)),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0097B2) : const Color(0xFFE2E2E2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      opt.iconAsset,
                      width: w(16),
                      height: w(16),
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4C4C4C),
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (_) => Icon(Icons.miscellaneous_services, size: w(16), color: const Color(0xFF4C4C4C)),
                    ),
                    SizedBox(width: w(6)),
                    Text(
                      opt.label,
                      style: GoogleFonts.inter(
                        fontSize: fs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4C4C4C),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String Function(String) itemLabel,
    required ValueChanged<String?> onChanged,
    required double Function(double) w,
    required double Function(double) fs,
  }) {
    final String? effectiveValue =
        (value != null && items.contains(value)) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: fs(14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF09101D).withOpacity(0.8),
          ),
        ),
        SizedBox(height: w(4)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.symmetric(horizontal: w(12)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(w(8)),
              side: const BorderSide(color: Color(0xFFCBD0DC), width: 1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue as String?,
              isExpanded: true,
              hint: Text(
                items.isEmpty ? 'No options available' : 'Select...',
                style: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D).withOpacity(0.3)),
              ),
              style: GoogleFonts.sourceSans3(fontSize: fs(14), color: const Color(0xFF09101D)),
              items: items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(itemLabel(item)),
              )).toList(),
              onChanged: items.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed, double Function(double) w, double Function(double) fs, bool isSaving) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0097B2),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: w(12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w(8))),
        ),
        child: isSaving
            ? SizedBox(width: w(20), height: w(20), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: GoogleFonts.inter(fontSize: fs(14), fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    required VoidCallback onDelete,
    required double Function(double) w,
    required double Function(double) fs,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(10)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: w(2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: fs(14), fontWeight: FontWeight.w600, color: const Color(0xFF19213D))),
                    SizedBox(height: w(2)),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: fs(12), color: const Color(0xFF6D758F))),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(w(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(w(6)),
              ),
              child: Icon(Icons.delete_outline, size: w(18), color: const Color(0xFFE74C3C)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBusinessListTile(BusinessModel biz, double Function(double) w, double Function(double) fs) {
    final provider = Provider.of<PartnerProvider>(context, listen: false);
    final isRealEstate = biz.category.toUpperCase() == 'REAL_ESTATE';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(10)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(right: w(86)),
                child: InkWell(
                  onTap: () => _startEditBusiness(biz),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: w(2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(biz.name, style: GoogleFonts.inter(fontSize: fs(14), fontWeight: FontWeight.w600, color: const Color(0xFF19213D))),
                        SizedBox(height: w(2)),
                        Text('${biz.category} · ${biz.location ?? 'N/A'}', style: GoogleFonts.inter(fontSize: fs(12), color: const Color(0xFF6D758F))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _startEditBusiness(biz),
                      child: Container(
                        padding: EdgeInsets.all(w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Icon(Icons.edit_outlined, size: w(18), color: const Color(0xFF0097B2)),
                      ),
                    ),
                    SizedBox(width: w(8)),
                    GestureDetector(
                      onTap: () => provider.deleteBusiness(biz.id),
                      child: Container(
                        padding: EdgeInsets.all(w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Icon(Icons.delete_outline, size: w(18), color: const Color(0xFFE74C3C)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: w(8)),
          if (!isRealEstate)
            Row(
              children: [
                Expanded(
                  child: Text('Media: ${biz.media.length}', style: GoogleFonts.inter(fontSize: fs(12), color: const Color(0xFF6D758F))),
                ),
                Wrap(
                  spacing: w(8),
                  runSpacing: w(6),
                  children: [
                    GestureDetector(
                      onTap: () => _uploadBusinessMedia(biz.id, isVideo: false),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Text('Add Photo', style: GoogleFonts.inter(fontSize: fs(11), fontWeight: FontWeight.w600, color: const Color(0xFF0097B2))),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _uploadBusinessMedia(biz.id, isVideo: true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Text('Add Video', style: GoogleFonts.inter(fontSize: fs(11), fontWeight: FontWeight.w600, color: const Color(0xFF0097B2))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (!isRealEstate && biz.media.isNotEmpty) ...[
            SizedBox(height: w(8)),
            SizedBox(
              height: w(52),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: biz.media
                    .map(
                      (m) => _buildMediaThumb(
                        fileUrl: m.fileUrl,
                        mediaType: m.mediaType,
                        size: w(52),
                        onDelete: () => _deleteBusinessMedia(m.id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmenityListTile(AmenityModel amenity, double Function(double) w, double Function(double) fs) {
    final provider = Provider.of<PartnerProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(10)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(right: w(86)),
                child: InkWell(
                  onTap: () => _startEditAmenity(amenity),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: w(2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(amenity.name, style: GoogleFonts.inter(fontSize: fs(14), fontWeight: FontWeight.w600, color: const Color(0xFF19213D))),
                        SizedBox(height: w(2)),
                        Text('${amenity.amenityType} · ${amenity.location ?? 'N/A'}', style: GoogleFonts.inter(fontSize: fs(12), color: const Color(0xFF6D758F))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _startEditAmenity(amenity),
                      child: Container(
                        padding: EdgeInsets.all(w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Icon(Icons.edit_outlined, size: w(18), color: const Color(0xFF0097B2)),
                      ),
                    ),
                    SizedBox(width: w(8)),
                    GestureDetector(
                      onTap: () => provider.deleteAmenity(amenity.id),
                      child: Container(
                        padding: EdgeInsets.all(w(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(w(6)),
                        ),
                        child: Icon(Icons.delete_outline, size: w(18), color: const Color(0xFFE74C3C)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: w(8)),
          Row(
            children: [
              Expanded(
                child: Text('Media: ${amenity.media.length}', style: GoogleFonts.inter(fontSize: fs(12), color: const Color(0xFF6D758F))),
              ),
              Wrap(
                spacing: w(8),
                runSpacing: w(6),
                children: [
                  GestureDetector(
                    onTap: () => _uploadAmenityMedia(amenity.id, isVideo: false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0097B2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(w(6)),
                      ),
                      child: Text('Add Photo', style: GoogleFonts.inter(fontSize: fs(11), fontWeight: FontWeight.w600, color: const Color(0xFF0097B2))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _uploadAmenityMedia(amenity.id, isVideo: true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(6)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0097B2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(w(6)),
                      ),
                      child: Text('Add Video', style: GoogleFonts.inter(fontSize: fs(11), fontWeight: FontWeight.w600, color: const Color(0xFF0097B2))),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (amenity.media.isNotEmpty) ...[
            SizedBox(height: w(8)),
            SizedBox(
              height: w(52),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: amenity.media
                    .map(
                      (m) => _buildMediaThumb(
                        fileUrl: m.fileUrl,
                        mediaType: m.mediaType,
                        size: w(52),
                        onDelete: () => _deleteAmenityMedia(m.id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromotionsCard(BuildContext context, double scale) {
    // Figma dimensions: 390 width base
    double w(double v) => v * scale;
    double fs(double v) => v * scale;
    final businesses = Provider.of<PartnerProvider>(context, listen: false)
        .businesses
        .where((b) => !b.id.startsWith('property:'))
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(w(10)),
          topRight: Radius.circular(w(10)),
        ),
      ),
      child: Column(
        children: [
          // Header Section - Create a promotion
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(15), vertical: w(20)),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFCBD0DC), width: 2),
              ),
            ),
            child: Row(
              children: [
                // Cloud icon with circular border
                Container(
                  width: w(50),
                  height: w(50),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFCBD0DC), width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: w(22),
                      color: const Color(0xFFCBD0DC),
                    ),
                  ),
                ),
                SizedBox(width: w(10)),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a promotion',
                        style: GoogleFonts.inter(
                          fontSize: fs(15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Select and upload the image of your choice',
                        style: GoogleFonts.inter(
                          fontSize: fs(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA9ACB4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button - matching Figma (rotated X icon)
                GestureDetector(
                  onTap: () {
                    // Handle close/expand
                  },
                  child: Container(
                    width: w(25),
                    height: w(50),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close,
                      size: w(15),
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: w(15)),

          // Photo upload area with dashed border
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(21)),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: const Color(0xFFCBD0DC),
                strokeWidth: 2,
                borderRadius: w(15),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: w(10), vertical: w(20)),
                child: Column(
                  children: [
                    // Photo button with dashed border
                    GestureDetector(
                      onTap: () => _pickImage(isVideo: false, forPromotion: true),
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: Colors.black,
                          strokeWidth: 1,
                          borderRadius: w(5),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: w(22), vertical: w(17)),
                          child: Column(
                            children: [
                              _promotionImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(w(5)),
                                      child: Image.file(
                                        _promotionImage!,
                                        width: w(50),
                                        height: w(50),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_outlined,
                                      size: w(25),
                                      color: Colors.black,
                                    ),
                              if (_promotionImage == null)
                                Text(
                                  'Photo',
                                  style: GoogleFonts.inter(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: w(10)),
                    // Choose file text
                    Text(
                      'Choose a file or drag and drop it here',
                      style: GoogleFonts.inter(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: w(5)),
                    // Format text
                    Text(
                      'JPEG, PNG format up to 20MB',
                      style: GoogleFonts.inter(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA9ACB4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: w(10)),
                    // Browse button
                    GestureDetector(
                      onTap: () => _pickImage(isVideo: false, forPromotion: true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: w(20), vertical: w(5)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w(8)),
                          border:
                              Border.all(color: const Color(0xFFA9ACB4), width: 1),
                        ),
                        child: Text(
                          'Browse',
                          style: GoogleFonts.inter(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF54575C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: w(10)),

          // Guidelines text
          Padding(
            padding: EdgeInsets.symmetric(vertical: w(5), horizontal: w(21)),
            child: Text(
              'Please carefully follow the above guidelines when uploading a file',
              style: GoogleFonts.inter(
                fontSize: fs(11),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E8E8E),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),

          SizedBox(height: w(10)),

          // Title input field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(21)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Enter your title for Promotion',
                        style: GoogleFonts.sourceSans3(
                          fontSize: fs(16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF09101D).withOpacity(0.8),
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: GoogleFonts.sourceSans3(
                          fontSize: fs(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDA1414).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(8)),
                // Input field
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: TextField(
                    controller: _promotionTitleController,
                    style: GoogleFonts.sourceSans3(
                      fontSize: fs(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF09101D),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ramadan Kareem promotion',
                      hintStyle: GoogleFonts.sourceSans3(
                        fontSize: fs(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09101D).withOpacity(0.25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: w(16), vertical: w(12)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: w(8)),
                // Info message
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: w(16), vertical: w(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEEF2),
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: w(16),
                        color: const Color(0xFF858C94),
                      ),
                      SizedBox(width: w(4)),
                      Flexible(
                        child: Text(
                          'Give a catchy heading for your promotion',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF394452),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: w(15)),

          // Link promotion to a business
          if (businesses.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w(21)),
              child: _buildDropdown(
                label: 'Business (optional)',
                value: _promotionBusinessId,
                items: businesses.map((b) => b.id).toList(),
                itemLabel: (id) => businesses.firstWhere((b) => b.id == id, orElse: () => businesses.first).name,
                onChanged: (v) => setState(() => _promotionBusinessId = v),
                w: w,
                fs: fs,
              ),
            ),

          if (businesses.isNotEmpty) SizedBox(height: w(15)),

          // Price and Discount row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(21)),
            child: Row(
              children: [
                // Enter the price section
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Enter the price',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF09101D).withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: w(5)),
                      Flexible(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(w(8)),
                          ),
                          child: TextField(
                            controller: _promotionPriceController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.sourceSans3(
                              fontSize: fs(16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF09101D),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rs',
                              hintStyle: GoogleFonts.sourceSans3(
                                fontSize: fs(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF09101D).withOpacity(0.6),
                              ),
                              contentPadding: EdgeInsets.all(w(10)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: w(10)),
                // Enter discount section
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Enter discount',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF09101D).withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: w(5)),
                      Flexible(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(w(8)),
                          ),
                          child: TextField(
                            controller: _promotionDiscountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.sourceSans3(
                              fontSize: fs(16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF09101D),
                            ),
                            decoration: InputDecoration(
                              hintText: '%',
                              hintStyle: GoogleFonts.sourceSans3(
                                fontSize: fs(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF09101D).withOpacity(0.6),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: w(12), vertical: w(10)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w(8)),
                                borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                              ),
                              isDense: true,
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                size: w(20),
                                color: const Color(0xFF858C94),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: w(15)),

          // Promotion description field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(21)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Promotion description',
                        style: GoogleFonts.sourceSans3(
                          fontSize: fs(16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF09101D).withOpacity(0.8),
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: GoogleFonts.sourceSans3(
                          fontSize: fs(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDA1414).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w(8)),
                // Input field (multiline)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: TextField(
                    controller: _promotionDescriptionController,
                    maxLines: 3,
                    style: GoogleFonts.sourceSans3(
                      fontSize: fs(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF09101D),
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'A treat box for your whole family',
                      hintStyle: GoogleFonts.sourceSans3(
                        fontSize: fs(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09101D).withOpacity(0.25),
                        height: 1.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: w(16), vertical: w(12)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w(8)),
                        borderSide: const BorderSide(color: Color(0xFF858C94), width: 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: w(8)),
                // Info message
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: w(16), vertical: w(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEEF2),
                    borderRadius: BorderRadius.circular(w(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: w(16),
                        color: const Color(0xFF858C94),
                      ),
                      SizedBox(width: w(4)),
                      Flexible(
                        child: Text(
                          'Write a note to make your promotion understandable',
                          style: GoogleFonts.sourceSans3(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF394452),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: w(15)),

          // Create Promotion button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w(21)),
            child: Consumer<PartnerProvider>(
              builder: (context, pp, _) => SizedBox(
                width: double.infinity,
                height: w(48),
                child: ElevatedButton(
                  onPressed: pp.isSaving ? null : () => _submitPromotion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0097B2),
                    padding: EdgeInsets.symmetric(horizontal: w(14), vertical: 0),
                    minimumSize: Size(double.infinity, w(48)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w(8)),
                    ),
                  ),
                  child: pp.isSaving
                      ? SizedBox(
                          width: w(20), height: w(20),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Create Promotion',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: fs(16),
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: w(15)),

          // Existing promotions list
          ...Provider.of<PartnerProvider>(context).promotions.map((promo) {
            return Padding(
              padding: EdgeInsets.only(left: w(21), right: w(21), bottom: w(10)),
              child: Container(
                padding: EdgeInsets.all(w(12)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(w(10)),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    // Promotion image or icon
                    Container(
                      width: w(50),
                      height: w(50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w(8)),
                        color: const Color(0xFFEEF1F7),
                      ),
                      child: promo.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(w(8)),
                              child: Image.network(
                                promo.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.local_offer,
                                  size: w(24),
                                  color: const Color(0xFF0097B2),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.local_offer,
                              size: w(24),
                              color: const Color(0xFF0097B2),
                            ),
                    ),
                    SizedBox(width: w(12)),
                    // Promotion info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title,
                            style: GoogleFonts.inter(
                              fontSize: fs(14),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          if (promo.price != null || promo.discountPct != null)
                            Text(
                              [
                                if (promo.price != null) 'Rs ${promo.price!.toStringAsFixed(0)}',
                                if (promo.discountPct != null) '${promo.discountPct!.toStringAsFixed(0)}% off',
                              ].join(' - '),
                              style: GoogleFonts.inter(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6D758F),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Promotion'),
                            content: Text('Delete "${promo.title}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          Provider.of<PartnerProvider>(context, listen: false)
                              .deletePromotion(promo.id);
                        }
                      },
                      child: Icon(Icons.delete_outline, size: w(20), color: const Color(0xFFE74C3C)),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: w(10)),
        ],
      ),
    );
  }

  Future<void> _submitPromotion(BuildContext context) async {
    final title = _promotionTitleController.text.trim();
    final description = _promotionDescriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promotion title')),
      );
      return;
    }

    final partnerProvider = Provider.of<PartnerProvider>(context, listen: false);
    String? imageUrl;

    // Upload promotion image if selected
    if (_promotionImage != null) {
      imageUrl = await partnerProvider.uploadPromotionImage(_promotionImage!.path);
    }

    final data = <String, dynamic>{
      'title': title,
      if (description.isNotEmpty) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (_promotionBusinessId != null) 'businessId': _promotionBusinessId,
    };

    // Parse price
    final priceText = _promotionPriceController.text.trim();
    if (priceText.isNotEmpty) {
      final price = double.tryParse(priceText);
      if (price != null) data['price'] = price;
    }

    // Parse discount
    final discountText = _promotionDiscountController.text.trim();
    if (discountText.isNotEmpty) {
      final discount = double.tryParse(discountText);
      if (discount != null) data['discountPct'] = discount;
    }

    final success = await partnerProvider.createPromotion(data);

    if (mounted) {
      if (success) {
        _promotionTitleController.clear();
        _promotionPriceController.clear();
        _promotionDiscountController.clear();
        _promotionDescriptionController.clear();
        setState(() => _promotionImage = null);
        setState(() => _promotionBusinessId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promotion created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(partnerProvider.error ?? 'Failed to create promotion')),
        );
      }
    }
  }

  Widget _buildShareApplication(BuildContext context, double scale) {
    return InkWell(
      onTap: () {
        Share.share('Check out OneConnect - your one-stop community app! Download now.');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Share icon
          SvgPicture.asset(
            'assets/icons/share.svg',
            width: 20 * scale,
            height: 20 * scale,
            colorFilter: const ColorFilter.mode(
              Color(0xFF02A6C3),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8 * scale),
          // Share text
          Text(
            'Share the application',
            style: GoogleFonts.inter(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF19213D),
            ),
          ),
        ],
      ),
    );
  }
}

// Dashed border painter
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double currentX = 0;

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      while (currentX < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(currentX, currentX + dashWidth),
          Offset.zero,
        );
        currentX += dashWidth + dashSpace;
      }
      currentX = 0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}






