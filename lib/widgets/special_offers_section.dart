import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/promotion_model.dart';

class SpecialOffersSection extends StatelessWidget {
  final List<PromotionModel> promotions;

  const SpecialOffersSection({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFE53935),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/lsicon_badge-promotion-filled.png',
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Special offers for you',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: promotions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (_, index) => _PromotionCard(promo: promotions[index]),
          ),
        ),
      ],
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final PromotionModel promo;

  const _PromotionCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 312,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: promo.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(promo.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/Product Photo (1).png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  promo.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF000000),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/images/lsicon_badge-promotion-filled.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        promo.discountPct != null
                            ? 'Up to ${promo.discountPct!.toStringAsFixed(0)}% off'
                            : 'Special offer',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF000000),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  promo.description ?? 'No description available',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      promo.price != null
                          ? 'Rs. ${promo.price!.toStringAsFixed(0)}'
                          : 'Rs. --',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (promo.discountPct != null && promo.price != null)
                          ? 'Rs. ${(promo.price! / (1 - (promo.discountPct! / 100))).toStringAsFixed(0)}'
                          : '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
