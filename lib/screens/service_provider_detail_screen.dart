import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../providers/service_provider_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/location_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/service_provider_model.dart';
import '../models/review_model.dart';
import '../utils/contact_utils.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/photos_and_videos_section.dart';
import '../widgets/partner_media_gallery.dart';
import '../widgets/profile_image.dart';
import '../widgets/location_section.dart';
import '../mixins/responsive_mixin.dart';
import '../utils/map_utils.dart';
import '../utils/media_url.dart';

class ServiceProviderDetailScreen extends StatefulWidget {
  final String? providerName;
  final String? serviceType;
  final String? specialty;
  final String? providerId;

  const ServiceProviderDetailScreen({
    super.key,
    this.providerName,
    this.serviceType,
    this.specialty,
    this.providerId,
  });

  @override
  State<ServiceProviderDetailScreen> createState() => _ServiceProviderDetailScreenState();
}

class _ServiceProviderDetailScreenState extends State<ServiceProviderDetailScreen>
    with ResponsiveMixin {
  // Set to track selected job tags
  final Set<String> _selectedJobs = {};
  bool _showAllReviews = false;

  // Check if current service type is Doctor
  bool get _isDoctor => widget.serviceType?.toLowerCase() == 'doctor';

  String _displayServiceType(ServiceProviderModel? detail) {
    final raw = (detail?.serviceType ?? widget.serviceType ?? '').trim();
    if (raw.isEmpty) return 'Service';
    final lower = raw.toLowerCase().replaceAll('_', ' ');
    return lower
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _to12Hour(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';
    try {
      return DateFormat.jm().format(DateFormat('HH:mm').parseStrict(raw));
    } catch (_) {
      return raw;
    }
  }

  List<String> _fallbackSkills(String? serviceType) {
    final type = (serviceType ?? '').toUpperCase();
    const fallbackByType = <String, List<String>>{
      'LAUNDRY': [
        'Dry cleaning',
        'Steam press',
        'Stain removal',
        'Curtain cleaning',
        'Shoe cleaning',
      ],
      'PLUMBER': [
        'Minor leak repair',
        'Major leak repair',
        'Drainage cleaning',
        'Flush and sink repair',
        'Fixture installation',
        'Geyser installation',
        'Pipe repair',
        'Appliances install',
        'Gas line plumbing',
      ],
      'ELECTRICIAN': [
        'Wiring and rewiring',
        'Switchboard repair',
        'Fan installation',
        'Circuit breaker fix',
        'Generator troubleshooting',
      ],
      'PAINTER': [
        'Interior painting',
        'Exterior painting',
        'Texture paint',
        'Wall putty work',
        'Wood polish',
      ],
      'CARPENTER': [
        'Door repair',
        'Cabinet fitting',
        'Furniture assembly',
        'Kitchen woodwork',
        'Bed repair',
      ],
      'BARBER': [
        'Hair cut',
        'Beard trim',
        'Hair styling',
        'Head massage',
        'Facial clean-up',
      ],
      'MAID': [
        'Deep cleaning',
        'Kitchen cleaning',
        'Laundry and ironing',
        'Baby care',
        'Elderly care',
      ],
      'SALON': [
        'Hair styling',
        'Facial treatment',
        'Manicure and pedicure',
        'Makeup service',
        'Waxing',
      ],
      'REAL_ESTATE': [
        'Property buying',
        'Property selling',
        'Rental assistance',
        'Commercial listings',
        'Property valuation',
      ],
      'DOCTOR': [
        'General consultation',
        'Follow-up checkup',
        'Prescription review',
        'Health screening',
        'Second opinion',
      ],
      'WATER': [
        'Water tanker delivery',
        'Water filter installation',
        'RO maintenance',
        'Water quality testing',
        'Tank cleaning',
      ],
      'GAS': [
        'Gas leak repair',
        'Gas pipeline fitting',
        'Geyser service',
        'Regulator replacement',
        'Safety inspection',
      ],
    };

    return fallbackByType[type] ?? const [];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.providerId != null) {
        final p = Provider.of<ServiceProviderProvider>(context, listen: false);
        p.fetchDetail(widget.providerId!);
        p.fetchProviderMedia(widget.providerId!);
      }
      Provider.of<FavoriteProvider>(context, listen: false).hydrateFavorites();
    });
  }

  void _handleVote(String reviewId, String voteType) {
    if (widget.providerId == null) return;
    Provider.of<ServiceProviderProvider>(context, listen: false)
        .voteReview(widget.providerId!, reviewId, voteType);
  }





  String _normalizeServiceType(String? rawType) {
    final st = (rawType ?? '').trim().toLowerCase().replaceAll('_', ' ');
    if (st.contains('salon') || st.contains('beauty')) return 'salon';
    if (st.contains('plumber') || st.contains('plumbing')) return 'plumber';
    if (st.contains('electric')) return 'electrician';
    if (st.contains('paint')) return 'painter';
    if (st.contains('carpent')) return 'carpenter';
    if (st.contains('laundry') || st.contains('dry clean')) return 'laundry';
    if (st.contains('barber')) return 'barber';
    if (st.contains('maid') || st.contains('clean')) return 'maid';
    if (st.contains('real estate') || st.contains('property')) return 'real_estate';
    if (st.contains('doctor') || st.contains('health')) return 'doctor';
    if (st.contains('water')) return 'water';
    if (st.contains('gas')) return 'gas';
    return st;
  }

  // Icon size matching the list page for each service type
  double _getIconSize(String? rawType) {
    final st = _normalizeServiceType(rawType);
    switch (st) {
      case 'laundry':
      case 'barber':
      case 'salon':
      case 'beauty':
      case 'maid':
        return 109;
      case 'electrician':
        return 59;
      case 'plumber':
      case 'painter':
      case 'carpenter':
        return 89;
      case 'real estate':
      case 'real_estate':
        return 80;
      default:
        return 59;
    }
  }

  // Extra vertical offset matching the list page
  double _getIconOffsetY(String? rawType) {
    final st = _normalizeServiceType(rawType);
    switch (st) {
      case 'laundry':
      case 'barber':
      case 'salon':
      case 'beauty':
        return 10;
      case 'electrician':
        return -2;
      case 'real estate':
      case 'real_estate':
        return -4;
      default:
        return 0;
    }
  }

  // Get the monochrome header icon path based on service type
  String _getCategoryHeaderIconPath(String? rawType) {
    final serviceType = _normalizeServiceType(rawType);
    switch (serviceType) {
      case 'plumber':
        return 'assets/icons/plumber_header_icon.svg';
      case 'electrician':
        return 'assets/icons/xxx.svg';
      case 'painter':
        return 'assets/icons/painter_header_icon.svg';
      case 'carpenter':
        return 'assets/icons/carpenter_header_icon.svg';
      case 'laundry':
        return 'assets/icons/laundry_header_icon.svg';
      case 'barber':
        return 'assets/icons/barber_header_icon.svg';
      case 'maid':
        return 'assets/icons/maid_header_icon.svg';
      case 'salon':
      case 'beauty':
        return 'assets/icons/salon_header_icon.svg';
      case 'water':
        return 'assets/icons/water_header_icon.svg';
      case 'gas':
        return 'assets/icons/gas_header_icon.svg';
      case 'real estate':
      case 'real_estate':
        return 'assets/icons/fluent_real_estate_filled.svg';
      case 'health':
      case 'doctor':
        return 'assets/icons/header_doctor_icon.svg';
      default:
        return 'assets/icons/plumber_header_icon.svg';
    }
  }

  IconData _serviceFallbackIcon(String? rawType) {
    final type = (rawType ?? '').toLowerCase().trim();
    switch (type) {
      case 'plumber':
        return Icons.plumbing_outlined;
      case 'electrician':
        return Icons.electrical_services_outlined;
      case 'painter':
        return Icons.format_paint_outlined;
      case 'carpenter':
        return Icons.handyman_outlined;
      case 'laundry':
        return Icons.local_laundry_service_outlined;
      case 'barber':
      case 'salon':
      case 'beauty':
        return Icons.content_cut_outlined;
      case 'maid':
        return Icons.cleaning_services_outlined;
      case 'doctor':
      case 'health':
        return Icons.local_hospital_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'gas':
        return Icons.local_fire_department_outlined;
      case 'real_estate':
        return Icons.home_work_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _serviceTypeIconAsset(String? rawType) {
    final type = (rawType ?? '').toLowerCase().trim();
    switch (type) {
      case 'laundry':
        return 'assets/images/laundry_icon.svg';
      case 'plumber':
        return 'assets/images/plumber_icon.svg';
      case 'electrician':
        return 'assets/images/electrician_icon.svg';
      case 'painter':
        return 'assets/images/painter_icon.svg';
      case 'carpenter':
        return 'assets/images/carpenter_icon.svg';
      case 'barber':
        return 'assets/images/barber_icon.svg';
      case 'maid':
        return 'assets/images/maid_icon.svg';
      case 'salon':
      case 'beauty':
        return 'assets/images/salon_icon.svg';
      case 'doctor':
      case 'health':
        return 'assets/icons/doctor_icon.svg';
      case 'water':
        return 'assets/images/water_icon.svg';
      case 'gas':
        return 'assets/images/gas_icon.svg';
      case 'real_estate':
        return 'assets/images/real_estate_icon.svg';
      default:
        return 'assets/images/store_icon.svg';
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Consumer<ServiceProviderProvider>(
      builder: (context, provider, _) {
    final detail = widget.providerId != null ? provider.getDetail(widget.providerId!) : null;
    final providerMedia = widget.providerId != null
        ? provider.getProviderMedia(widget.providerId!)
        : const <MediaItem>[];
    final mediaItems = (providerMedia.isNotEmpty ? providerMedia : (detail?.media ?? const <MediaItem>[]))
        .map((m) => PartnerGalleryItem(
              id: m.id,
              mediaType: m.mediaType,
              fileUrl: m.fileUrl,
            ))
        .toList();
    final photosAndVideosUrls = mediaItems
        .map((m) => m.fileUrl)
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section - Stack with overlapping icon (matching list pages)
              Builder(
                builder: (context) {
                  final resolvedServiceType = detail?.serviceType ?? widget.serviceType;
                  final categoryIconPath = _getCategoryHeaderIconPath(resolvedServiceType);
                  final double actualIconW = _getIconSize(resolvedServiceType);
                  final double extraOffset = (actualIconW - 59) / 2;
                  final double iconOffY = _getIconOffsetY(resolvedServiceType);
                  final double iconOverlap = rw(20);

                  return Padding(
                    padding: EdgeInsets.only(bottom: iconOverlap),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(rw(50)),
                              bottomRight: Radius.circular(rw(50)),
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: rh(38),
                                bottom: rh(32) + iconOverlap,
                              ),
                              child: Row(
                                children: [
                                  // Back button
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: rw(56),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icons/back_arrow_teal.svg',
                                        width: rw(20),
                                        height: rw(20),
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF3195AB),
                                          BlendMode.srcIn,
                                        ),
                                        placeholderBuilder: (_) => Icon(
                                          Icons.arrow_back_ios,
                                          size: rw(20),
                                          color: const Color(0xFF3195AB),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Title
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _displayServiceType(detail),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: rfs(27),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF515151),
                                          letterSpacing: -0.28,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Share icon
                                  GestureDetector(
                                    onTap: () {
                                      final name = widget.providerName ?? 'Service Provider';
                                      final type = _displayServiceType(detail);
                                      Share.share('Check out $name ($type) on OneConnect!');
                                    },
                                    child: Container(
                                      width: rw(56),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icons/share.svg',
                                        width: rw(24),
                                        height: rw(24),
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF156385),
                                          BlendMode.srcIn,
                                        ),
                                        placeholderBuilder: (_) => Icon(
                                          Icons.share,
                                          size: rw(24),
                                          color: const Color(0xFF156385),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Category icon — overlapping at bottom center
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -rw(27 + extraOffset + iconOffY),
                          child: Center(
                            child: SizedBox(
                              width: rw(actualIconW),
                              height: rw(actualIconW),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SvgPicture.asset(
                                  categoryIconPath,
                                  colorFilter: categoryIconPath.endsWith('fluent_real_estate_filled.svg')
                                      ? null
                                      : const ColorFilter.mode(
                                          Color(0xFF515151),
                                          BlendMode.srcIn,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Scrollable Content - Expanded with SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                // Profile Section - Exact Figma layout with proper spacing
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(15),
                    vertical: rw(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image - Circular with border (90x90)
                      Container(
                        width: rw(90),
                        height: rw(90),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF044870), // Exact Figma border color
                            width: rw(2),
                          ),
                        ),
                        child: ClipOval(
                          child: buildProfileImage(
                            detail?.imageUrl,
                            fallbackIcon: _serviceFallbackIcon(
                              detail?.serviceType ?? widget.serviceType,
                            ),
                            iconSize: rw(45),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: rw(8)), // Exact Figma gap
                      
                      // Profile Info - Flexible layout to prevent overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and Heart Row - flexible layout
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Name Column - flexible
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail?.name ?? widget.providerName ?? 'Service Provider',
                                        style: GoogleFonts.inter(
                                          fontSize: rfs(14),
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF353535), // Exact Figma color
                                          letterSpacing: 0.11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: rw(4)),
                                      Text(
                                        _isDoctor
                                          ? (widget.specialty ?? _displayServiceType(detail))
                                          : _displayServiceType(detail),
                                        style: GoogleFonts.inter(
                                          fontSize: rfs(12),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF353535), // Exact Figma color
                                          letterSpacing: 0.17,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(width: rw(8)),
                                
                                // Heart icon synced with global favorites
                                Consumer<FavoriteProvider>(
                                  builder: (context, favProvider, _) {
                                    final providerId = widget.providerId ?? detail?.id ?? '';
                                    final isFav = favProvider.isServiceProviderFavorited(providerId);
                                    final isPending = favProvider.isPending(providerId);
                                    return GestureDetector(
                                      onTap: isPending || providerId.isEmpty
                                          ? null
                                          : () => favProvider.toggleServiceProviderFavorite(providerId),
                                      child: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border,
                                        size: rw(20),
                                        color: isFav ? Colors.red : Colors.black,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            
                            SizedBox(height: rw(4)), // Exact Figma gap
                            
                            // Rating Section - flexible layout
                            Row(
                              children: [
                                // Stars - flexible
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) => Padding(
                                    padding: EdgeInsets.only(right: rw(2)),
                                    child: SvgPicture.asset(
                                      'assets/icons/star_filled.svg',
                                      width: rw(15),
                                      height: rw(15),
                                      colorFilter: ColorFilter.mode(
                                        index < (detail?.rating.round() ?? 0)
                                          ? const Color(0xFFFFCD29)
                                          : const Color(0xFFD9D9D9),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  )),
                                ),
                                
                                SizedBox(width: rw(8)),
                                
                                // Rating and Reviews Text - flexible
                                Flexible(
                                  child: Text(
                                    '${detail?.rating.toStringAsFixed(1) ?? '0'} (${detail?.reviewCount ?? 0} Reviews)',
                                    style: GoogleFonts.inter(
                                      fontSize: rfs(12),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF353535), // Exact Figma color
                                      letterSpacing: 0.17,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: rw(5)),
                
                // Statistics Cards Section - Exact Figma layout
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(15),
                    vertical: rw(10),
                  ),
                  child: Builder(
                    builder: (context) {
                      final statCards = <Widget>[];

                      if (_isDoctor) {
                        if (detail?.patientsCount != null) {
                          statCards.add(
                            _buildStatCard(
                              'Patients',
                              '${detail!.patientsCount}+',
                              'assets/icons/patient_icon.svg',
                            ),
                          );
                        }
                        if (_hasText(detail?.workingSince)) {
                          statCards.add(
                            _buildStatCard(
                              'Working Since',
                              detail!.workingSince!,
                              'assets/icons/Working Since.svg',
                            ),
                          );
                        }
                        if (_hasText(detail?.doctorId)) {
                          statCards.add(
                            _buildStatCard(
                              "Doctor's ID",
                              detail!.doctorId!,
                              'assets/images/grocery_store/id_badge_icon.svg',
                            ),
                          );
                        }
                        if (detail?.experienceYears != null) {
                          statCards.add(
                            _buildStatCard(
                              'Experience',
                              '${detail!.experienceYears}+',
                              'assets/icons/experience_icon.svg',
                            ),
                          );
                        }
                      } else {
                        if (detail != null && detail.jobsCompleted > 0) {
                          statCards.add(
                            _buildStatCard(
                              'Jobs completed',
                              '${detail.jobsCompleted}',
                              'assets/icons/jobs.svg',
                            ),
                          );
                        }
                        if (_hasText(detail?.workingSince)) {
                          statCards.add(
                            _buildStatCard(
                              'Working Since',
                              detail!.workingSince!,
                              'assets/icons/Working Since.svg',
                            ),
                          );
                        }
                        if (_hasText(detail?.vendorId)) {
                          statCards.add(
                            _buildStatCard(
                              'Vendor ID',
                              detail!.vendorId!,
                              'assets/images/grocery_store/id_badge_icon.svg',
                            ),
                          );
                        }
                        if (_hasText(detail?.responseTime)) {
                          statCards.add(
                            _buildStatCard(
                              'Response Time',
                              detail!.responseTime!,
                              'assets/icons/tdesign_time.svg',
                            ),
                          );
                        }
                      }

                      if (statCards.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Wrap(
                        spacing: rw(20),
                        runSpacing: rw(20),
                        children: statCards
                            .map(
                              (card) => SizedBox(
                                width: (MediaQuery.of(context).size.width - rw(30) - rw(20)) / 2,
                                child: card,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: rw(10)),

                // Unified: Jobs Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(15),
                    vertical: rw(10),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFE3E3E3),
                        width: rw(1),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final dynamicSkills = (detail?.skills ?? const <String>[])
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();
                          final tags = dynamicSkills.isNotEmpty
                              ? dynamicSkills
                              : _fallbackSkills(detail?.serviceType ?? widget.serviceType);

                          if (tags.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: rw(8),
                              runSpacing: rw(8),
                              alignment: WrapAlignment.start,
                              children: tags
                                  .map((tag) => _buildJobTag(tag, const Color(0xFFF6F6F6), const Color(0xFF4C4C4C)))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: rh(10)),
                _buildTimingAndDistanceSection(detail),
                SizedBox(height: rh(9)),
                if (_hasText(detail?.address) || _hasText(detail?.city))
                  LocationSection(
                    locationText: detail?.address ?? detail?.city ?? '',
                    latitude: detail?.latitude,
                    longitude: detail?.longitude,
                    entityName: detail?.name,
                  ),
                
                if (_normalizeServiceType(detail?.serviceType ?? widget.serviceType) == 'doctor' &&
                    _hasText(detail?.phone)) ...[
                  SizedBox(height: rh(15)),
                  _buildContactCard(context, detail!.phone!),
                ],

                SizedBox(height: rh(9)),
                  
                  // Service/Consultation Charges Section - Flexible layout
                  if ((_isDoctor ? detail?.consultationCharge : detail?.serviceCharge) != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(15),
                      vertical: rw(10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA), // Exact Figma background
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE3E3E3),
                          width: rw(1),
                        ),
                        bottom: BorderSide(
                          color: const Color(0xFFE3E3E3),
                          width: rw(1),
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left section with service charge - flexible
                        Flexible(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Charges Starting from',
                                style: GoogleFonts.inter(
                                  fontSize: rfs(10),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000), // Exact Figma color
                                ),
                              ),
                              SizedBox(height: rw(10)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: rw(30),
                                    height: rw(30),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/money_hand_icon.svg',
                                        width: rw(21),
                                        height: rw(24),
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF000000), // Exact Figma color
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: rw(5)),
                                  Flexible(
                                    child: Text(
                                      'Rs ${(_isDoctor ? detail?.consultationCharge : detail?.serviceCharge)!.toStringAsFixed(0)}',
                                      style: GoogleFonts.inter(
                                        fontSize: rfs(20),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF000000), // Exact Figma color
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: rw(15)), // Reduced gap

                        // Right section with disclaimer - flexible
                        Flexible(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.all(rw(10)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDFDF), // Exact Figma background
                              borderRadius: BorderRadius.circular(rw(10)),
                            ),
                            child: Text(
                              _isDoctor
                                  ? 'Service Charges are per visit charges excluding any additional tests or procedures'
                                  : 'Service Charges are per visit charges excluding parts and labor cost',
                              style: GoogleFonts.inter(
                                fontSize: rfs(10),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFFF2222), // Exact Figma color
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Photos and Videos Section
                  PhotosAndVideosSection(
                    imageUrls: photosAndVideosUrls,
                  ),
                  
                  // Profile Card - Above Customer Reviews
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(15),
                      vertical: rw(15),
                    ),
                    child: _buildProfileCard(detail),
                  ),

                  // Reviews Section - Different titles for Doctor vs Others
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(15),
                      vertical: rw(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Reviews',
                          style: GoogleFonts.afacad(
                            fontSize: rfs(17),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF272727), // Exact Figma color
                          ),
                        ),
                        SizedBox(height: rw(15)),

                        // Reviews from backend data
                        if (detail?.reviews.isEmpty ?? true)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: rw(20)),
                            child: Center(
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: GoogleFonts.inter(
                                  fontSize: rfs(13),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF696969),
                                ),
                              ),
                            ),
                          )
                        else
                          ...(_showAllReviews
                                  ? detail!.reviews
                                  : detail!.reviews.take(3).toList())
                              .asMap()
                              .entries
                              .map((entry) {
                            final review = entry.value;
                            final dateStr = DateFormat('dd-MM-yyyy').format(review.createdAt);
                            final timeStr = DateFormat('h:mm a').format(review.createdAt);
                            return Column(
                              children: [
                                if (entry.key > 0) SizedBox(height: rw(15)),
                                _buildFigmaReviewCard(
                                      review: review,
                                      profileImage: _serviceTypeIconAsset(
                                        detail.serviceType ?? widget.serviceType,
                                      ),
                                      reviewMediaUrl: review.mediaUrl,
                                      reviewMediaType: review.mediaType,
                                      onlineStatusImage: review.userPhotoUrl,
                                      userName: review.userName,
                                      serviceType: _displayServiceType(detail),
                                      rating: review.rating.toStringAsFixed(1),
                                      ratingText: review.ratingText ?? '',
                                      reviewText: review.reviewText ?? '',
                                      date: dateStr,
                                      time: timeStr,
                                      backgroundColor: const Color(0xFFF9F9F9),
                                    ),
                              ],
                            );
                          }),
                        if ((detail?.reviews.length ?? 0) > 3)
                          Padding(
                            padding: EdgeInsets.only(top: rw(10)),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAllReviews = !_showAllReviews;
                                });
                              },
                              child: Text(
                                _showAllReviews ? 'See Less' : 'See More',
                                style: GoogleFonts.inter(
                                  fontSize: rfs(13),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3195AB),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PartnerMediaGallery(
                    title: 'Partner Media',
                    items: mediaItems,
                    hideWhenEmpty: true,
                  ),
                  
                  SizedBox(height: rw(20)),
                    ],
                  ),
                ),
              ),
              
              // Book Now Button - At bottom (only button size)
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: rw(23)),
                child: Container(
                  width: rw(322),
                  height: rh(48),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final providerId = widget.providerId;
                        final rawServiceType = (detail?.serviceType ?? widget.serviceType ?? '')
                            .trim()
                            .toUpperCase()
                            .replaceAll(' ', '_');
                        if (providerId == null || providerId.isEmpty || rawServiceType.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unable to place booking right now')),
                            );
                          }
                          return;
                        }

                        final bookingProvider =
                            Provider.of<BookingProvider>(context, listen: false);
                        final locationProvider =
                            Provider.of<LocationProvider>(context, listen: false);
                        await locationProvider.fetchCurrentLocation();
                        final booked = await bookingProvider.createBooking(
                          providerId: providerId,
                          serviceType: rawServiceType,
                          bookingDate: DateTime.now(),
                          userLatitude: locationProvider.latitude,
                          userLongitude: locationProvider.longitude,
                        );
                        if (!booked) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  bookingProvider.error ?? 'Booking request failed',
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking request sent to provider successfully'),
                            ),
                          );
                        }
                        // Professional app flow: booking is tracked in DB and appears
                        // in partner-side booking inbox (/bookings/me). Contact remains optional.
                      },
                      borderRadius: BorderRadius.circular(rw(8)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF02A6C3),
                          borderRadius: BorderRadius.circular(rw(8)),
                          border: Border.all(
                            color: const Color(0xFF008EA8),
                            width: rw(4),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(rw(6)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: const Color(0xFF0097B2)),
                              Positioned(
                                left: rw(265),
                                top: -rh(85),
                                child: Transform.rotate(
                                  angle: 0.785398, // 45deg diagonal accent
                                  child: Container(
                                    width: rw(54),
                                    height: rh(318),
                                    color: const Color(0xFF008EA8),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Book Now',
                                    style: GoogleFonts.roboto(
                                      fontSize: rfs(16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: rw(10)),
                                  SvgPicture.asset(
                                    'assets/images/arrow_right.svg',
                                    width: rw(16),
                                    height: rw(16),
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  // TIMING AND DISTANCE SECTION
  Widget _buildTimingAndDistanceSection(ServiceProviderModel? detail) {
    final opening = detail?.openingTime?.toString();
    final closing = detail?.closingTime?.toString();
    final timeText = (opening != null &&
            opening.isNotEmpty &&
            closing != null &&
            closing.isNotEmpty)
        ? '${_to12Hour(opening)} - ${_to12Hour(closing)}'
        : '9:00 AM - 6:00 PM';
    
    // For service providers, we don't have operatingDays in model, using default
    const daysText = 'Monday - Saturday';
    
    final distanceText = (detail?.distanceKm != null) 
        ? '${detail!.distanceKm!.toStringAsFixed(1)} Km away' 
        : '3.2 Km away';

    return Container(
      width: rw(360),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF3F3F3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Opening Hours - Left side
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tick Circle Icon
                SvgPicture.asset(
                  'assets/icons/doctor_tick_circle.svg',
                  width: rw(25),
                  height: rw(25),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0097B2),
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) => Icon(
                    Icons.check_circle,
                    size: rw(25),
                    color: const Color(0xFF0097B2),
                  ),
                ),
                SizedBox(width: rw(5)),
                // Text Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Opening Hours
                    Text(
                      'Opening Hours',
                      style: GoogleFonts.roboto(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: rh(2)),
                    // Time
                    Text(
                      timeText,
                      style: GoogleFonts.roboto(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: rh(2)),
                    // Days
                    Text(
                      daysText,
                      style: GoogleFonts.roboto(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Distance - Right side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distance Icon
              SvgPicture.asset(
                'assets/icons/doctor_distance_icon.svg',
                width: rw(25),
                height: rw(24.943),
                placeholderBuilder: (context) => Icon(
                  Icons.directions_walk,
                  size: rw(25),
                  color: const Color(0xFF0097B2),
                ),
              ),
              SizedBox(width: rw(5)),
              // Text Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance
                  Text(
                    'Distance',
                    style: GoogleFonts.roboto(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: rh(2)),
                  // Km away
                    Text(
                      distanceText,
                    style: GoogleFonts.roboto(
                      fontSize: rfs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF202020),
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

  Widget _buildContactCard(BuildContext context, String phone) {
    final String whatsapp = phone; // Using same number for whatsapp

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(15),
        vertical: rw(15),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phone Section
          Flexible(
            child: GestureDetector(
              onTap: () async {
                if (phone.isNotEmpty) {
                  final url = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                }
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/phone_icon.svg',
                    width: rw(19),
                    height: rw(19),
                    placeholderBuilder: (_) => Icon(Icons.phone, size: rw(19), color: const Color(0xFF3195AB)),
                  ),
                  SizedBox(width: rw(5)),
                  Flexible(
                    child: Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: rw(40)),

          // WhatsApp Section
          Flexible(
            child: GestureDetector(
              onTap: () async {
                await openWhatsAppForNumber(context, whatsapp);
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/whatsapp_icon.svg',
                    width: rw(25),
                    height: rw(25),
                    placeholderBuilder: (_) => Icon(Icons.chat, size: rw(25), color: Colors.green),
                  ),
                  SizedBox(width: rw(5)),
                  Flexible(
                    child: Text(
                      'WhatsApp',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
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

  Widget _buildStatCard(String title, String value, String iconPath) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(rw(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon section
            Container(
              width: rw(50), // Increased container width
              padding: EdgeInsets.symmetric(
                horizontal: rw(10),
                vertical: rw(5),
              ),
              child: SvgPicture.asset(
                iconPath,
                width: rw(35), // Increased size significantly
                height: rw(35), // Increased size significantly
                colorFilter: const ColorFilter.mode(
                  Color(0xFF3195AB), // Teal color
                  BlendMode.srcIn,
                ),
              ),
            ),
            
            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: rfs(12),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000), // Exact Figma color
                      height: 1.33,
                    ),
                  ),
                  SizedBox(height: rw(2)),
                  Text(
                    value.length > 12 ? '${value.substring(0, 8)}...' : value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: rfs(12),
                      fontWeight: FontWeight.w700, // Bold
                      color: const Color(0xFF000000), // Exact Figma color
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTag(String jobName, Color backgroundColor, Color textColor) {
    final isSelected = _selectedJobs.contains(jobName);
    final selectedColor = const Color(0xFFE8F5FA); // Light blue from image
    
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedJobs.remove(jobName);
            } else {
              _selectedJobs.add(jobName);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: rw(14),
            vertical: rw(6),
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : backgroundColor,
            borderRadius: BorderRadius.circular(rw(12)),
          ),
          child: Text(
            jobName,
            style: GoogleFonts.inter(
              fontSize: rfs(12),
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFigmaReviewCard({
    ReviewModel? review,
    required String profileImage,
    String? reviewMediaUrl,
    String? reviewMediaType,
    String? onlineStatusImage,
    required String userName,
    required String serviceType,
    required String rating,
    required String ratingText,
    required String reviewText,
    required String date,
    required String time,
    required Color backgroundColor,
  }) {
    return Builder(
      builder: (context) => Container(
        width: rw(344), // Exact Figma width
        padding: EdgeInsets.all(rw(10)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(rw(15)), // Exact Figma border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.15), // Exact Figma shadow
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      child: Column(
        children: [
          // Profile Section
          Row(
            children: [
              // Dish Image - 56x56dp size (left side)
              Container(
                width: rw(56), // 56.dp equivalent
                height: rw(56), // 56.dp equivalent
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(rw(8)), // Slightly rounded corners, not circular
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rw(8)),
                  child: Builder(
                    builder: (_) {
                      final resolvedReviewMedia = resolveMediaUrl(reviewMediaUrl);
                      final isVideo = (reviewMediaType ?? '').toUpperCase() == 'VIDEO' ||
                          (resolvedReviewMedia?.toLowerCase().endsWith('.mp4') ?? false);
                      if (resolvedReviewMedia != null && resolvedReviewMedia.isNotEmpty && !isVideo) {
                        return Image.network(
                          resolvedReviewMedia,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(rw(8)),
                              ),
                              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[600], size: rw(22)),
                            );
                          },
                        );
                      }
                      return profileImage.toLowerCase().endsWith('.svg')
                          ? Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(rw(10)),
                              child: SvgPicture.asset(
                                profileImage,
                                fit: BoxFit.contain,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF515151),
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : Image.asset(
                              profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(rw(8)),
                                  ),
                                  child: Icon(Icons.fastfood, color: Colors.grey[500], size: rw(24)),
                                );
                              },
                            );
                    },
                  ),
                ),
              ),
              
              SizedBox(width: rw(9)), // Exact Figma gap
              
              // User Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Service Type - Aligned in straight vertical line
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer name - aligned directly above dish name
                        Text(
                          userName,
                          style: GoogleFonts.afacad(
                            fontSize: rfs(15),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000), // Exact Figma color
                          ),
                        ),
                        
                        SizedBox(height: rw(2)), // Small gap between name and dish name
                        
                        // Dish name (service type) - directly below customer name
                        Text(
                          serviceType,
                          style: GoogleFonts.afacad(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF5858), // Exact Figma red color
                            height: 1.33, // Exact Figma line height
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: rw(5)),
                    
                    // Rating Section
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/star_rating.svg',
                          width: rw(14),
                          height: rw(13),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFCD29), // Exact Figma star color
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: rw(5)),
                        Text(
                          rating,
                          style: GoogleFonts.poppins(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000),
                          ),
                        ),
                        SizedBox(width: rw(5)),
                        Text(
                          ratingText,
                          style: GoogleFonts.poppins(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Customer Profile Image - Circular (right side)
              Container(
                width: rw(42),
                height: rw(42),
                padding: EdgeInsets.only(right: rw(5)),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rw(21)),
                  child: onlineStatusImage != null && onlineStatusImage.startsWith('http')
                    ? Image.network(
                        onlineStatusImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
                            child: Icon(Icons.person, color: Colors.grey[500], size: rw(20)),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
                        child: Icon(Icons.person, color: Colors.grey[500], size: rw(20)),
                      ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: rw(10)), // Exact Figma gap
          
          // Review Text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              reviewText,
              style: GoogleFonts.afacad(
                fontSize: rfs(14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF000000),
                height: 1.33, // Exact Figma line height
              ),
            ),
          ),
          
          SizedBox(height: rw(10)),
          
          // Footer Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Helpful Section
              Row(
                children: [
                  Text(
                    'Helpful ?',
                    style: GoogleFonts.afacad(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(width: rw(5)),
                  GestureDetector(
                    onTap: review != null ? () => _handleVote(review.id, 'helpful') : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/thumbs_up.svg',
                          width: rw(15),
                          height: rw(15),
                          colorFilter: ColorFilter.mode(
                            review?.userVote == 'helpful' ? const Color(0xFF3195AB) : const Color(0xFF000000),
                            BlendMode.srcIn,
                          ),
                        ),
                        if (review != null && review.helpfulCount > 0) ...[
                          SizedBox(width: rw(2)),
                          Text('${review.helpfulCount}', style: GoogleFonts.afacad(fontSize: rfs(12), color: const Color(0xFF696969))),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    ' | ',
                    style: GoogleFonts.afacad(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  GestureDetector(
                    onTap: review != null ? () => _handleVote(review.id, 'unhelpful') : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/thumbs_down.svg',
                          width: rw(15),
                          height: rw(15),
                          colorFilter: ColorFilter.mode(
                            review?.userVote == 'unhelpful' ? const Color(0xFFFF5858) : const Color(0xFF000000),
                            BlendMode.srcIn,
                          ),
                        ),
                        if (review != null && review.unhelpfulCount > 0) ...[
                          SizedBox(width: rw(2)),
                          Text('${review.unhelpfulCount}', style: GoogleFonts.afacad(fontSize: rfs(12), color: const Color(0xFF696969))),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              // Date and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: rw(61), // Exact Figma width
                    child: Text(
                      date,
                      style: GoogleFonts.afacad(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(height: rw(1)), // Exact Figma gap
                  SizedBox(
                    width: rw(61), // Exact Figma width
                    child: Text(
                      time,
                      style: GoogleFonts.afacad(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6A6A6A), // Exact Figma gray color
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
  
  Widget _buildProfileCard(ServiceProviderModel? detail) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(rw(15)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture - Circular
            Container(
              width: rw(60),
              height: rw(60),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: buildProfileImage(
                  detail?.imageUrl,
                  fallbackIcon: _serviceFallbackIcon(
                    detail?.serviceType ?? widget.serviceType,
                  ),
                  iconSize: rw(30),
                ),
              ),
            ),

            SizedBox(width: rw(12)),

            // Name and Followers Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with Verified Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          detail?.name ?? widget.providerName ?? 'Service Provider',
                          style: GoogleFonts.inter(
                            fontSize: rfs(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rw(4)),
                  // Review Count
                  Text(
                    '${detail?.reviewCount ?? 0} Reviews',
                    style: GoogleFonts.inter(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: rw(8)),
            
            // Give a Review Button
            Flexible(
              child: GestureDetector(
                onTap: () {
                  GiveReviewDialog.show(
                    context: context,
                    itemName: detail?.name ?? widget.providerName ?? 'Service Provider',
                    itemLocation: detail?.address ?? widget.specialty ?? 'Location',
                    itemRating: detail?.rating ?? 0,
                    reviewCount: detail?.reviewCount ?? 0,
                    itemImage: detail?.imageUrl,
                    itemTypeHint: 'SERVICE',
                    onSubmit: (rating, review, hasPhoto, hasVideo) async {
                      final providerId = widget.providerId;
                      if (providerId == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot submit review: missing provider ID'), backgroundColor: Colors.red),
                          );
                        }
                        return;
                      }
                      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                      final ratingText = rating >= 4 ? 'Excellent' : rating >= 3 ? 'Good' : rating >= 2 ? 'Average' : 'Poor';
                      final success = await reviewProvider.submitServiceProviderReview(
                        providerId,
                        rating: rating.toDouble(),
                        ratingText: ratingText,
                        reviewText: review.isNotEmpty ? review : null,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Review submitted!' : (reviewProvider.error ?? 'Failed to submit review')),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                        if (success) {
                          final submitted = reviewProvider.lastSubmittedReview;
                          if (submitted != null) {
                            Provider.of<ServiceProviderProvider>(context, listen: false)
                                .applySubmittedReview(providerId, submitted);
                          }
                        }
                      }
                    },
                  );
                },
                child: Container(
                  width: rw(130),
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(8),
                    vertical: rh(8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3195AB), // Teal color
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Give a Review',
                      style: GoogleFonts.inter(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Doctor-specific review card with #F8F8F8 background per Figma
  Widget _buildDoctorReviewCard({
    ReviewModel? review,
    required String userName,
    required String rating,
    required String ratingText,
    required String reviewText,
    required String date,
    required String time,
  }) {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(rw(12)),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8), // Figma: #F8F8F8 background
          borderRadius: BorderRadius.circular(rw(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with user name and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User name
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: rfs(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF353535),
                  ),
                ),
                // Rating
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star_filled.svg',
                      width: rw(16),
                      height: rw(16),
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFFCD29),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: rw(4)),
                    Text(
                      rating,
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353535),
                      ),
                    ),
                    SizedBox(width: rw(4)),
                    Text(
                      ratingText,
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF696969),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: rw(10)),
            // Review text
            Text(
              reviewText,
              style: GoogleFonts.inter(
                fontSize: rfs(12),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF505050),
                height: 1.5,
              ),
            ),
            SizedBox(height: rw(10)),
            // Date and time
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$date  $time',
                  style: GoogleFonts.inter(
                    fontSize: rfs(10),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF696969),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



