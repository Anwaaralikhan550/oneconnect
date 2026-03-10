import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../utils/map_utils.dart';
import '../widgets/profile_image.dart';
import '../widgets/separator_line.dart';
import 'property_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel? property;

  const PropertyDetailScreen({super.key, this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isPropertyDetailsExpanded = true;
  bool _isDescriptionExpanded = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.property?.id;
      if (id != null && id.isNotEmpty) {
        Provider.of<PropertyProvider>(context, listen: false).fetchDetail(id);
      }
    });
  }

  void _openPropertyListForAgent() {
    final partnerId = _property?.partnerId;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyScreen(
          partnerId: partnerId,
          agentName: _property?.partner?.businessName,
        ),
      ),
    );
  }

  /// Returns fresh data from provider if available, otherwise constructor data.
  PropertyModel? get _property {
    final id = widget.property?.id;
    if (id != null && id.isNotEmpty) {
      return Provider.of<PropertyProvider>(context, listen: false).getDetail(id) ?? widget.property;
    }
    return widget.property;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Base design width from Figma
  static const double _baseWidth = 390.0;

  // Responsive scale factor
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / _baseWidth).clamp(0.85, 1.2);
  }

  // Responsive size helper
  double _rs(BuildContext context, double size) {
    return size * _getScaleFactor(context);
  }

  // Fixed responsive width
  double _rw(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / _baseWidth * screenWidth).clamp(width * 0.85, width * 1.15);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, _, __) => Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Header with Image Carousel
              _buildHeader(context),

              // Scrollable Content
              Expanded(
                child: SizedBox(
                  width: _rw(context, 390),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Price Section
                        _buildPriceSection(context),

                        SizedBox(height: _rs(context, 10)),

                        // Quick View Section
                        _buildQuickViewSection(context),

                        SizedBox(height: _rs(context, 10)),

                        // Address Section
                        _buildAddressSection(context),

                        SizedBox(height: _rs(context, 10)),

                        // Separator Line
                        SeparatorLine(width: _rw(context, 390), height: 1.02),

                        SizedBox(height: _rs(context, 10)),

                        // Property Details Section (Expandable)
                        _buildPropertyDetailsSection(context),

                        SizedBox(height: _rs(context, 10)),

                        // Separator Line
                        SeparatorLine(width: _rw(context, 390), height: 1.02),

                        SizedBox(height: _rs(context, 10)),

                        // Description Section (Expandable)
                        _buildDescriptionSection(context),

                        SizedBox(height: _rs(context, 10)),

                        // Separator Line
                        SeparatorLine(width: _rw(context, 390), height: 1.02),

                        SizedBox(height: _rs(context, 10)),

                        // Agent Section
                        _buildAgentSection(context),

                        SizedBox(height: _rs(context, 30)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scaleFactor = _getScaleFactor(context);
    final containerWidth = _rw(context, 390);

    return SizedBox(
      width: containerWidth,
      child: Stack(
        children: [
          // Image Carousel
          Container(
            width: containerWidth,
            height: _rs(context, 304),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_rs(context, 20)),
                bottomRight: Radius.circular(_rs(context, 20)),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_rs(context, 20)),
                bottomRight: Radius.circular(_rs(context, 20)),
              ),
              child: _buildImageCarousel(),
            ),
          ),
          // Bottom overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: containerWidth,
              height: _rs(context, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFFFF).withOpacity(1.0),
                    const Color(0xFF8E8E8E).withOpacity(1.0),
                  ],
                  stops: const [1.0, 1.0],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: _rs(context, 20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - "Super hot property" with fire icon
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icon_fire.svg',
                        width: _rs(context, 25),
                        height: _rs(context, 25),
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_fire_department,
                            size: _rs(context, 25),
                            color: const Color(0xFFF24822),
                          );
                        },
                      ),
                      SizedBox(width: _rs(context, 10)),
                      Text(
                        _property?.title ?? 'Sukh Chain - Boys Hostel',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: _rs(context, 18),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                          height: 1.2,
                          letterSpacing: 0.00622 * _rs(context, 18),
                        ),
                      ),
                    ],
                  ),

                  // Right side - "Rental" badge
                  Container(
                    padding: EdgeInsets.all(_rs(context, 5)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(_rs(context, 5)),
                    ),
                    child: Text(
                      _property?.purpose == 'SALE' ? 'Sale' : 'Rental',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: _rs(context, 16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353535),
                        height: 1.3,
                        letterSpacing: 0.0105 * _rs(context, 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Offer Badge Section (Bottom Overlay)
          // Header Controls (Top Overlay) - Exact Figma specs
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(
                horizontal: _rs(context, 30),
                vertical: _rs(context, 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button - Exact Figma specs: 52x52px, transparent bg, 25px radius
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Center(
                      child: Icon(Icons.arrow_back,color: Colors.white),
                    ),
                  ),

                  // Share Button - Exact Figma specs: 21x20.79px icon with 10px padding, transparent bg
                  GestureDetector(
                    onTap: () => _handleShare(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent, // Transparent as per Figma
                      ),
                      child: Center(
                        child: Icon(Icons.ios_share_outlined,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(
                horizontal: _rs(context, 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black.withOpacity(.3),
                    child: Container(child: IconButton(onPressed: () {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }, icon: Icon(Icons.arrow_back_ios,size: 30,))),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black.withOpacity(.3),
                    child: Container(child: IconButton(onPressed: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }, icon: Icon(Icons.arrow_forward_ios_outlined,size: 30,))),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final List<String?> imageUrls = [];
    if (_property != null && _property!.images.isNotEmpty) {
      for (final img in _property!.images) {
        imageUrls.add(img.imageUrl);
      }
    }
    if (imageUrls.isEmpty) {
      imageUrls.add(_property?.mainImageUrl);
    }

    if (imageUrls.length == 1) {
      return buildProfileImage(imageUrls.first, fallbackIcon: Icons.home, iconSize: 60);
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return buildProfileImage(imageUrls[index], fallbackIcon: Icons.home, iconSize: 60);
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      width: _rw(context, 390),
      padding: EdgeInsets.symmetric(vertical: _rs(context, 10)),
      child: Center(
        child: SizedBox(
          width: _rw(context, 279),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon_money_hand.svg',
                width: _rs(context, 30),
                height: _rs(context, 30),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.attach_money,
                    size: _rs(context, 30),
                    color: const Color(0xFF000000),
                  );
                },
              ),
              SizedBox(width: _rs(context, 5)),
              Text(
                _property?.price != null ? 'PKR ${_property!.price!.toStringAsFixed(0)}/month' : 'Price not available',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: _rs(context, 20),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                  height: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickViewSection(BuildContext context) {
    return Container(
      width: _rw(context, 360),
      padding: EdgeInsets.symmetric(vertical: _rs(context, 10)),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: _rs(context, 20),
        runSpacing: _rs(context, 10),
        children: [
          _buildQuickViewItem(context, 'assets/images/icon_ruler_measure.svg', _property?.sqft != null ? '${_property!.sqft!.toStringAsFixed(0)} sqft' : 'Not specified'),
          _buildQuickViewItem(context, 'assets/images/icon_bed_2.svg', '${_property?.beds?.toString() ?? '2'} Bed'),
          _buildQuickViewItem(context, 'assets/images/icon_bath_shower_2.svg', '${_property?.baths?.toString() ?? '2'} Bath'),
          _buildQuickViewItem(context, 'assets/images/icon_kitchen.svg', '${_property?.kitchen?.toString() ?? '1'} Kitchen'),
        ],
      ),
    );
  }

  Widget _buildQuickViewItem(BuildContext context, String iconPath, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container - exact Figma specs: 20x20px
        SizedBox(
          width: _rs(context, 20),
          height: _rs(context, 20),
          child: Image.asset(
            iconPath,
            width: _rs(context, 20),
            height: _rs(context, 20),
            fit: BoxFit.contain,
            color: const Color(0xFFFF5E5E), // Exact Figma color
            errorBuilder: (context, error, stackTrace) {
              // Fallback icons matching the type
              IconData fallbackIcon = Icons.info_outline;
              if (label.contains('Marla')) {
                fallbackIcon = Icons.straighten;
              } else if (label.contains('Bed')) {
                fallbackIcon = Icons.bed;
              } else if (label.contains('Bath')) {
                fallbackIcon = Icons.bathtub;
              } else if (label.contains('Kitchen')) {
                fallbackIcon = Icons.soup_kitchen;
              }

              return Icon(
                fallbackIcon,
                size: _rs(context, 16),
                color: const Color(0xFFFF5E5E),
              );
            },
          ),
        ),
        SizedBox(width: _rs(context, 5)), // Exact 5px gap from Figma
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: _rs(context, 12),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF000000),
            height: 1.21,
          ),
        ),
      ],
    );
  }

  // Share functionality - Fully functional with comprehensive property details
  Future<void> _handleShare(BuildContext context) async {
    try {
      final p = _property;
      await Share.share(
        'Check out this amazing property!\n\n'
        'Super hot property - ${p?.title ?? 'Property'}\n'
        'Price: ${p?.price != null ? 'PKR ${p!.price!.toStringAsFixed(0)}/month' : 'Price not available'}\n'
        'Location: ${p?.location ?? ''}\n\n'
        'Features:\n'
        '${p?.beds ?? 2} Bedrooms\n'
        '${p?.baths ?? 2} Bathrooms\n'
        '${p?.kitchen ?? 1} Kitchen\n'
        '${p?.sqft != null ? '${p!.sqft!.toStringAsFixed(0)} sqft' : 'Size not specified'}\n'
        '${p?.purpose == 'SALE' ? 'For Sale' : 'For Rent'}\n\n'
        'Property ID: ${p?.id ?? 'N/A'}\n\n'
        'Listing provided by:\n'
        'Rao Estate and Builders\n\n'
        'Contact us for more details!',
        subject: 'Property Listing - ${p?.title ?? ''}',
      );
    } catch (e) {
      // Show error message if share fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFFF5252),
          ),
        );
      }
    }
  }

  Widget _buildAddressSection(BuildContext context) {
    return Container(
      width: _rw(context, 360),
      padding: EdgeInsets.symmetric(
        horizontal: _rs(context, 25),
        vertical: _rs(context, 15),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(_rs(context, 15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location Icon and Address
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rs(context, 3),
                    vertical: _rs(context, 1),
                  ),
                  child: Image.asset(
                    'assets/images/icon_location.svg',
                    width: _rs(context, 16.5),
                    height: _rs(context, 18.51),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.location_on,
                        size: _rs(context, 18),
                        color: const Color(0xFFFF5C5C),
                      );
                    },
                  ),
                ),
                SizedBox(width: _rs(context, 5)),
                Flexible(
                  child: Text(
                    _property?.location ?? 'Address not available',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: _rs(context, 14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000000),
                      height: 1.21,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: _rs(context, 20)),

          // View on Map Button - Exact Figma specs (106x25px, #696969)
          GestureDetector(
            onTap: () async {
              final p = _property;
              if (p?.latitude != null && p?.longitude != null) {
                await openMapAtCoordinates(
                  context,
                  latitude: p!.latitude!,
                  longitude: p.longitude!,
                  label: p.title,
                );
                return;
              }
              final location = p?.location ?? '';
              await openMapForQuery(context, location);
            },
            child: Container(
              width: _rs(context, 106),
              height: _rs(context, 25),
              decoration: BoxDecoration(
                color: const Color(0xFF696969), // Exact Figma gray
                borderRadius: BorderRadius.circular(_rs(context, 5)),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: _rs(context, 3)), // Text position x:3 from Figma
                child: Text(
                  'View on Map',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: _rs(context, 12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                    height: 1.21,
                    letterSpacing: 0.0121 * _rs(context, 12), // 1.21% letter spacing
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPropertyDetailsSection(BuildContext context) {
    return SizedBox(
      width: _rw(context, 390),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isPropertyDetailsExpanded = !_isPropertyDetailsExpanded;
              });
            },
            child: Container(
              width: _rw(context, 390),
              padding: EdgeInsets.only(
                left: _rs(context, 20),
                right: _rs(context, 30),
                top: _rs(context, 10),
                bottom: _rs(context, 10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/icon_details_list.svg',
                          width: _rs(context, 25),
                          height: _rs(context, 25),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.list,
                              size: _rs(context, 25),
                              color: const Color(0xFF4D4D4D),
                            );
                          },
                        ),
                        SizedBox(width: _rs(context, 10)),
                        Text(
                          'Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: _rs(context, 18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000000),
                            height: 1.2,
                            letterSpacing: 0.00622 * _rs(context, 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: _isPropertyDetailsExpanded ? 0 : 3.14159,
                    child: Image.asset(
                      'assets/images/icon_chevron_up.svg',
                      width: _rs(context, 20),
                      height: _rs(context, 20),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.keyboard_arrow_up,
                          size: _rs(context, 20),
                          color: const Color(0xFF000000),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (_isPropertyDetailsExpanded)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _rs(context, 30)),
              child: Column(
                children: [
                  _buildPropertyDetailItem(
                    context,
                    'assets/images/icon_document_2.svg',
                    Icons.description,
                    'Property Id',
                    _property?.id ?? 'N/A',
                  ),
                  SizedBox(height: _rs(context, 10)),
                  _buildPropertyDetailItem(
                    context,
                    'assets/images/icon_building.svg',
                    Icons.home,
                    'Type',
                    _property?.propertyType ?? 'House',
                  ),
                  SizedBox(height: _rs(context, 10)),
                  _buildPropertyDetailItem(
                    context,
                    'assets/images/icon_ruler_measure_2.svg',
                    Icons.square_foot,
                    'Area',
                    _property?.sqft != null ? '${_property!.sqft!.toStringAsFixed(0)} sqft' : 'Not specified',
                  ),
                  SizedBox(height: _rs(context, 10)),
                  _buildPropertyDetailItem(
                    context,
                    'assets/images/icon_tick_circle.svg',
                    Icons.check_circle,
                    'Purpose',
                    _property?.purpose == 'SALE' ? 'For Sale' : 'For Rent',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailItem(
      BuildContext context,
      String iconPath,
      IconData fallbackIcon,
      String label,
      String value,
      ) {
    return Container(
      width: _rw(context, 346),
      padding: EdgeInsets.symmetric(
        horizontal: _rs(context, 25),
        vertical: _rs(context, 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(_rs(context, 15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _rs(context, 150),
            child: Row(
              children: [
                Image.asset(
                  iconPath,
                  width: _rs(context, 20),
                  height: _rs(context, 20),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      size: _rs(context, 20),
                      color: const Color(0xFF4D4D4D),
                    );
                  },
                ),
                SizedBox(width: _rs(context, 15)),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: _rs(context, 14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF252525),
                      height: 1.21,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: _rs(context, 14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF000000),
                height: 1.21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return SizedBox(
      width: _rw(context, 390),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Container(
              width: _rw(context, 390),
              padding: EdgeInsets.only(
                left: _rs(context, 20),
                right: _rs(context, 30),
                top: _rs(context, 10),
                bottom: _rs(context, 10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/icon_description.svg',
                          width: _rs(context, 25),
                          height: _rs(context, 25),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.description,
                              size: _rs(context, 25),
                              color: const Color(0xFF4D4D4D),
                            );
                          },
                        ),
                        SizedBox(width: _rs(context, 10)),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: _rs(context, 18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000000),
                            height: 1.2,
                            letterSpacing: 0.00622 * _rs(context, 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: _isDescriptionExpanded ? 0 : 3.14159,
                    child: Image.asset(
                      'assets/images/icon_chevron_up.svg',
                      width: _rs(context, 20),
                      height: _rs(context, 20),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.keyboard_arrow_up,
                          size: _rs(context, 20),
                          color: const Color(0xFF000000),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (_isDescriptionExpanded)
            SizedBox(
              width: _rw(context, 390),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _rs(context, 25)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _rs(context, 25),
                        vertical: _rs(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(_rs(context, 15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _property?.description ?? 'No description available.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: _rs(context, 14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF000000),
                              height: 1.21,
                            ),
                          ),
                          SizedBox(height: _rs(context, 5)),
                          SizedBox(
                            width: _rw(context, 296),
                            child: GestureDetector(
                              onTap: _openPropertyListForAgent,
                              child: Text(
                                'See more',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: _rs(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0097B2),
                                  height: 1.21,
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
            ),
        ],
      ),
    );
  }

  Widget _buildAgentSection(BuildContext context) {
    return Container(
      width: _rw(context, 390),
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
      child: Column(
        children: [
          // "Listing provided by" header
          Container(
            width: _rw(context, 390),
            padding: EdgeInsets.symmetric(vertical: _rs(context, 10)),
            child: Center(
              child: Text(
                'Listing provided by',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: _rs(context, 18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                  height: 1.11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: _rs(context, 15)),

          // Agent Card
          Container(
            width: _rw(context, 363),
            height: _rs(context, 70),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(_rs(context, 20)),
            ),
            padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
            child: GestureDetector(
              onTap: _openPropertyListForAgent,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Agent Info
                Row(
                  children: [
                    // Agent Photo
                    Container(
                      width: _rs(context, 50),
                      height: _rs(context, 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFA8707),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: buildProfileImage(
                        _property?.partner?.profilePhotoUrl,
                        fallbackIcon: Icons.person,
                        iconSize: 24,
                      ),
                    ),

                    SizedBox(width: _rs(context, 12)),

                    // Agent Name
                    SizedBox(
                      width: _rs(context, 139),
                      child: Text(
                        _property?.partner?.businessName ?? 'Property Agent',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: _rs(context, 18),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B1B1D),
                          height: 1.11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: _rs(context, 40)),

                // Contact Action Buttons
                Row(
                  children: [
                    // Map Button
                    GestureDetector(
                      onTap: () async {
                        final p = _property;
                        if (p?.latitude != null && p?.longitude != null) {
                          await openMapAtCoordinates(
                            context,
                            latitude: p!.latitude!,
                            longitude: p.longitude!,
                            label: p.title,
                          );
                          return;
                        }
                        final location = p?.location ?? '';
                        await openMapForQuery(context, location);
                      },
                      child: Container(
                        width: _rs(context, 36.77),
                        height: _rs(context, 36.77),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(_rs(context, 38.75)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/icon_map.svg',
                            width: _rs(context, 24),
                            height: _rs(context, 24),
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.map,
                                size: _rs(context, 20),
                                color: const Color(0xFF3195AB),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: _rs(context, 10)),

                    // Phone Button
                    GestureDetector(
                      onTap: () async {
                        final phone = _property?.partner?.phone;
                        if (phone == null || phone.isEmpty) return;
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Container(
                        width: _rs(context, 36.77),
                        height: _rs(context, 36.77),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(_rs(context, 38.75)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/icon_phone.svg',
                            width: _rs(context, 18),
                            height: _rs(context, 18),
                            color: const Color(0xFF3195AB),
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.phone,
                                size: _rs(context, 18),
                                color: const Color(0xFF3195AB),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

