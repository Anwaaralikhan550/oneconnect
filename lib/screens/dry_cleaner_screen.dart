import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/contact_utils.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/photos_and_videos_section.dart';
import '../widgets/partner_media_gallery.dart';

class DryCleanerScreen extends StatelessWidget {
  final Map<String, dynamic>? cleanerData;

  const DryCleanerScreen({super.key, this.cleanerData});

  // Helper method to safely parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to safely parse int from dynamic value
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  ImageProvider _resolveImageProvider(dynamic value, String fallbackAsset) {
    final image = value?.toString().trim() ?? '';
    if (image.startsWith('http')) {
      return NetworkImage(image);
    }
    if (image.startsWith('assets/')) {
      return AssetImage(image);
    }
    return AssetImage(fallbackAsset);
  }

  String _operatingDaysText() {
    final raw = cleanerData?['operatingDays'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).join(', ');
    }
    return 'Monday - Sunday';
  }

  List<String> _mediaUrls() {
    final raw = cleanerData?['media'];
    final urls = <String>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map) {
          final map = Map<String, dynamic>.from(entry);
          final url = (map['fileUrl'] ?? map['mediaUrl'] ?? map['imageUrl'] ?? '')
              .toString()
              .trim();
          if (url.isNotEmpty) urls.add(url);
        } else if (entry is String) {
          final url = entry.trim();
          if (url.isNotEmpty) urls.add(url);
        }
      }
    }
    if (urls.isEmpty) {
      final single = (cleanerData?['imageUrl'] ?? cleanerData?['image'] ?? '')
          .toString()
          .trim();
      if (single.isNotEmpty) urls.add(single);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fixed Header and Profile Section
          Container(
            padding: const EdgeInsets.only(top: 55),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 15),

                // Profile Section
                _buildProfileSection(),
                const SizedBox(height: 15),

                // Category and Rating Row
                _buildCategoryAndRating(),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // Scrollable Hero Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Operating Hours Card
                  _buildOperatingHoursCard(),
                  const SizedBox(height: 15),

                  // Address Card
                  _buildAddressCard(),
                  const SizedBox(height: 15),

                  // Contact Card
                  _buildContactCard(),
                  const SizedBox(height: 15),

                  // Review Us Section
                  _buildReviewUsSection(),
                  const SizedBox(height: 15),

                  // Promotions Section
                  _buildPromotionsSection(),
                  const SizedBox(height: 15),

                  // Section Line Separator
                  _buildSectionSeparator(),

                  // Services Offered Section
                  _buildServicesSection(),

                  // Section Line Separator
                  _buildSectionSeparator(),

                  // Photos Section
                  PhotosAndVideosSection(imageUrls: _mediaUrls()),

                  // Section Line Separator
                  _buildSectionSeparator(),

                  // Customer Reviews Section
                  _buildCustomerReviewsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 35,
              height: 35,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back_arrow.svg',
                  width: 14.11,
                  height: 14.11,
                ),
              ),
            ),
          ),

          // Cleaner Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: _resolveImageProvider(
                  cleanerData?['logo'] ?? cleanerData?['image'],
                  'assets/images/grocery_store/store_logo.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Share Icon
          GestureDetector(
            onTap: () {
              final name = cleanerData?['name']?.toString() ?? 'Dry Cleaner';
              final location = cleanerData?['location']?.toString() ?? '';
              Share.share(
                  'Check out $name${location.isNotEmpty ? ' at $location' : ''} on OneConnect!');
            },
            child: SizedBox(
              width: 35,
              height: 35,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/share_icon.svg',
                  width: 21,
                  height: 20.79,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final String cleanerName =
        cleanerData?['name'] ?? 'PROFESSIONAL DRY CLEANERS';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Text(
            cleanerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF353535),
              letterSpacing: 0.112,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndRating() {
    final String category = cleanerData?['category'] ?? 'Dry Cleaner';
    final double rating = _parseDouble(cleanerData?['rating']) ?? 4.5;
    final int reviewCount = _parseInt(cleanerData?['reviewCount']) ?? 10;
    final fullCleanerId = cleanerData?['id']?.toString() ?? '16';
    final String cleanerId = fullCleanerId.length > 8
        ? fullCleanerId.substring(0, 8)
        : fullCleanerId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353535),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        // Star Rating Section
        Column(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: SvgPicture.asset(
                    'assets/icons/star_icon.svg',
                    width: 15,
                    height: 15,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 95,
              height: 16,
              child: Text(
                '$rating ($reviewCount Reviews)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        // ID Badge Section
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/id_badge_icon.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    '#ID ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      cleanerId,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingHoursCard() {
    final bool isOpen = cleanerData?['isOpen'] != false;
    final String openingTime =
        cleanerData?['openingTime']?.toString() ?? '09:00 am';
    final String closingTime =
        cleanerData?['closingTime']?.toString() ?? '09:00 pm';
    final String distance =
        cleanerData?['distance']?.toString() ?? '1.8 Km away';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F3F3), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Open Status Section
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/check_circle_icon.svg',
                  width: 25,
                  height: 25,
                ),
                const SizedBox(width: 5),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen ? 'Open now' : 'Closed',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '$openingTime - $closingTime',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _operatingDaysText(),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF727272),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Distance Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/distance_icon.svg',
                    width: 23.11,
                    height: 22.94,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Distance',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  distance,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF202020),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/location_pin_icon.svg',
            width: 16.5,
            height: 18.51,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                cleanerData?['location'] ?? 'Address not available',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    final String phone = cleanerData?['phone']?.toString() ?? '';
    final String whatsapp = cleanerData?['whatsapp']?.toString() ?? phone;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F3F3), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phone Section
          Row(
            children: [
              Container(
                width: 18.75,
                height: 18.75,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SvgPicture.asset(
                  'assets/icons/phone_icon.svg',
                  width: 18.75,
                  height: 18.75,
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phone.isNotEmpty ? phone : 'No phone available',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 60),

          // WhatsApp Section
          GestureDetector(
            onTap: () async {
              await openWhatsAppForNumber(context, whatsapp);
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  width: 25,
                  height: 25,
                ),
                const SizedBox(width: 5),
                Text(
                  whatsapp.isNotEmpty ? whatsapp : 'N/A',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewUsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Star Icons
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: SvgPicture.asset(
                    'assets/icons/star_icon.svg',
                    width: 15,
                    height: 15,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 20),

          // Review Button
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                GiveReviewDialog.show(
                  context: context,
                  itemName: cleanerData?['name'] ?? 'Dry Cleaner',
                  itemLocation: cleanerData?['location'] ?? 'Location',
                  itemRating: _parseDouble(cleanerData?['rating']) ?? 4.5,
                  reviewCount: _parseInt(cleanerData?['reviewCount']) ?? 10,
                  itemImage: cleanerData?['logo'] ?? cleanerData?['image'],
                  itemTypeHint: 'LAUNDRY',
                  onSubmit: (rating, review, hasPhoto, hasVideo) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Review submitted successfully!')),
                    );
                  },
                );
              },
              child: Container(
                width: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3195AB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Review Us',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/promotion_badge_icon.svg',
                width: 21.05,
                height: 22.13,
              ),
              const SizedBox(width: 10),
              const Text(
                'Special offers for you',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                  letterSpacing: 0.1116,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Scrolling Promotions
        SizedBox(
          height: 129.23,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildPromotionCard(
                  'assets/images/grocery_store/promotion_card_1.png'),
              const SizedBox(width: 25),
              _buildPromotionCard(
                  'assets/images/grocery_store/promotion_card_1.png'),
              const SizedBox(width: 25),
              _buildPromotionCard(
                  'assets/images/grocery_store/promotion_card_1.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(String imagePath) {
    return Container(
      width: 256,
      height: 129.23,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSectionSeparator() {
    return Container(
      width: double.infinity,
      height: 1.02,
      color: const Color(0xFFD8D8D8),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF999999), Color(0xFFFFFFFF)],
          stops: [0.0, 0.82],
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFD2D2D2), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF999999), Color(0xFFFFFFFF)],
                stops: [0.0, 0.91],
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Services Offered',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),

          // Services Icons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildServicePlaceholder(),
                _buildServicePlaceholder(),
                _buildServicePlaceholder(),
                _buildServicePlaceholder(),
                _buildServicePlaceholder(),
                _buildServicePlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildCustomerReviewsSection() {
    final reviews = (cleanerData?['reviewsList'] is List)
        ? (cleanerData!['reviewsList'] as List)
        : const [];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Customer Reviews',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF272727),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Review Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (reviews.isNotEmpty)
                  ...reviews.whereType<Map>().map((review) {
                    final r = Map<String, dynamic>.from(review);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildReviewCard(
                        r['userName'] ?? 'Anonymous',
                        r['date'] ?? '',
                        r['reviewText'] ?? '',
                      ),
                    );
                  })
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PartnerMediaGallery(
              items: reviews
                  .whereType<Map>()
                  .map((review) => Map<String, dynamic>.from(review))
                  .where((r) => (r['mediaUrl'] ?? r['imageUrl'] ?? '').toString().isNotEmpty)
                  .map((r) => PartnerGalleryItem(
                        id: (r['id'] ?? '').toString(),
                        mediaType: (r['mediaType'] ?? 'PHOTO').toString(),
                        fileUrl: (r['mediaUrl'] ?? r['imageUrl'] ?? '').toString(),
                      ))
                  .toList(),
              hideWhenEmpty: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String timeAgo, String review) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
              image: const DecorationImage(
                image:
                    AssetImage('assets/images/grocery_store/review_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Review Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: SvgPicture.asset(
                            'assets/icons/star_icon.svg',
                            width: 12,
                            height: 12,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF727272),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
