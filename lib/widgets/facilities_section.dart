import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data class for a single facility item.
class FacilityItem {
  final IconData icon;
  final String label;

  const FacilityItem({required this.icon, required this.label});
}

/// Shared facilities section for detail screens.
///
/// Figma: bg #FAFAFA with top/bottom borders, title "Facilities",
/// row of icon+label items, optional notice widget.
class FacilitiesSection extends StatelessWidget {
  final String title;
  final List<FacilityItem> items;
  final Widget? notice;

  const FacilitiesSection({
    super.key,
    this.title = 'Facilities',
    required this.items,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * sw;
    double rh(double v) => (v / 844) * sh;
    double rfs(double v) => (v / 390) * sw;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: rfs(14),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 16 / 14,
              ),
            ),
          ),
          SizedBox(height: rh(10)),
          // Facility items — chunked into rows of 4
          ...List.generate(
            (items.length / 4).ceil(),
            (rowIndex) {
              final start = rowIndex * 4;
              final end = (start + 4).clamp(0, items.length);
              final rowItems = items.sublist(start, end);
              return Padding(
                padding: EdgeInsets.only(
                  left: rw(20),
                  right: rw(20),
                  bottom: rowIndex < (items.length / 4).ceil() - 1 ? rh(10) : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: rowItems
                      .map((item) => _buildItem(item, rw, rh, rfs))
                      .toList(),
                ),
              );
            },
          ),
          // Optional notice
          if (notice != null) ...[
            SizedBox(height: rh(10)),
            Center(child: notice!),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    FacilityItem item,
    double Function(double) rw,
    double Function(double) rh,
    double Function(double) rfs,
  ) {
    return Flexible(
      child: Column(
        children: [
          Icon(item.icon, size: rw(30), color: const Color(0xFF4B4B4B)),
          SizedBox(height: rh(5)),
          Text(
            item.label,
            style: GoogleFonts.inter(
              fontSize: rfs(10),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
