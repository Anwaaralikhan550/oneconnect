import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';
import 'partner_media_gallery.dart';

/// Shared member reviews section for detail screens.
///
/// Figma: section title Inter 17px w700 #272727,
/// review cards #F9F9F9 bg, borderRadius 15, shadow.
class MemberReviewsSection extends StatefulWidget {
  final List<ReviewModel> reviews;
  final IconData fallbackIcon;
  final String sectionTitle;
  final void Function(String reviewId, String voteType)? onVote;
  final List<PartnerGalleryItem> mediaItems;

  const MemberReviewsSection({
    super.key,
    required this.reviews,
    this.fallbackIcon = Icons.store,
    this.sectionTitle = 'Member Reviews',
    this.onVote,
    this.mediaItems = const [],
  });

  @override
  State<MemberReviewsSection> createState() => _MemberReviewsSectionState();
}

class _MemberReviewsSectionState extends State<MemberReviewsSection> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * sw;
    double rh(double v) => (v / 844) * sh;
    double rfs(double v) => (v / 390) * sw;

    final totalReviews = widget.reviews.length;
    final visibleReviews =
        _showAllReviews ? widget.reviews : widget.reviews.take(3).toList();

    return Container(
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Text(
              widget.sectionTitle,
              style: GoogleFonts.inter(
                fontSize: rfs(17),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
              ),
            ),
          ),
          SizedBox(height: rh(15)),
          // Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Column(
              children: widget.reviews.isNotEmpty
                  ? visibleReviews
                      .map((r) => _LiveReviewCard(
                            review: r,
                            fallbackIcon: widget.fallbackIcon,
                            onVote: widget.onVote,
                          ))
                      .toList()
                  : [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: rh(20)),
                        child: Center(
                          child: Text(
                            'No reviews yet',
                            style: GoogleFonts.inter(
                              fontSize: rfs(14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF828282),
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          ),
          if (totalReviews > 3)
            Padding(
              padding: EdgeInsets.only(top: rh(4), left: rw(20), right: rw(20)),
              child: Align(
                alignment: Alignment.centerLeft,
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
            ),
          PartnerMediaGallery(
            title: 'Partner Media',
            items: widget.mediaItems,
            hideWhenEmpty: true,
          ),
        ],
      ),
    );
  }
}

/// Internal review card widget.
class _LiveReviewCard extends StatelessWidget {
  final ReviewModel review;
  final IconData fallbackIcon;
  final void Function(String reviewId, String voteType)? onVote;

  const _LiveReviewCard({
    required this.review,
    required this.fallbackIcon,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * sw;
    double rh(double v) => (v / 844) * sh;
    double rfs(double v) => (v / 390) * sw;

    return Container(
      width: rw(344),
      margin: EdgeInsets.only(bottom: rh(15)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(rw(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Review image placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: rw(56),
                  height: rw(56),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    fallbackIcon,
                    size: rw(30),
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: rw(9)),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: rh(5)),
                    // Rating row
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: rw(13.649),
                          color: const Color(0xFFFFCD29),
                        ),
                        SizedBox(width: rw(5)),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: rw(5)),
                        Flexible(
                          child: Text(
                            review.ratingText ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // User avatar
              Padding(
                padding: EdgeInsets.only(right: rw(5)),
                child: ClipOval(
                  child: review.userPhotoUrl != null
                      ? Image.network(
                          review.userPhotoUrl!,
                          width: rw(42),
                          height: rw(42),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(rw),
                        )
                      : _avatarFallback(rw),
                ),
              ),
            ],
          ),
          SizedBox(height: rh(10)),
          // Comment
          Text(
            review.reviewText ?? '',
            style: GoogleFonts.inter(
              fontSize: rfs(14),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: rh(10)),
          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Helpful
              Row(
                children: [
                  Text(
                    'Helpful ?',
                    style: GoogleFonts.inter(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: rw(5)),
                  GestureDetector(
                    onTap: () => onVote?.call(review.id, 'helpful'),
                    child: Icon(
                      Icons.thumb_up_outlined,
                      size: rw(18),
                      color: review.userVote == 'helpful'
                          ? const Color(0xFF3195AB)
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: rw(5)),
                  Text(
                    '|',
                    style: GoogleFonts.inter(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: rw(5)),
                  GestureDetector(
                    onTap: () => onVote?.call(review.id, 'unhelpful'),
                    child: Transform.rotate(
                      angle: 3.14159,
                      child: Icon(
                        Icons.thumb_up_outlined,
                        size: rw(18),
                        color: review.userVote == 'unhelpful'
                            ? const Color(0xFFFF5858)
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Date
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('dd-MM-yyyy').format(review.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: rw(8)),
                    Flexible(
                      child: Text(
                        DateFormat('hh:mm a').format(review.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6A6A6A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _avatarFallback(double Function(double) rw) {
    return Container(
      width: rw(42),
      height: rw(42),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Icon(Icons.person, size: rw(24), color: Colors.white),
    );
  }
}

