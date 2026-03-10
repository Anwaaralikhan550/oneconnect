import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared contact info section for detail screens.
///
/// Figma: bg #FAFAFA with top/bottom borders, phone + email rows
/// with teal icons, optional right-side notice widget.
class ContactInfoSection extends StatelessWidget {
  final String? phone;
  final String? email;
  final String? whatsapp;
  final Widget? notice;

  const ContactInfoSection({
    super.key,
    this.phone,
    this.email,
    this.whatsapp,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: rw(149),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Info',
                  style: GoogleFonts.inter(
                    fontSize: rfs(10),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 16 / 10,
                  ),
                ),
                SizedBox(height: rh(10)),
                if (phone != null && phone!.isNotEmpty)
                  _contactRow(Icons.phone, phone!, rw, rfs),
                if (phone != null && phone!.isNotEmpty)
                  SizedBox(height: rh(5)),
                if (email != null && email!.isNotEmpty)
                  _contactRow(Icons.email, email!, rw, rfs),
                if (whatsapp != null && whatsapp!.isNotEmpty) ...[
                  SizedBox(height: rh(5)),
                  _contactRow(Icons.chat, whatsapp!, rw, rfs),
                ],
              ],
            ),
          ),
          if (notice != null) ...[
            SizedBox(width: rw(34)),
            SizedBox(width: rw(149), child: notice!),
          ],
        ],
      ),
    );
  }

  Widget _contactRow(
    IconData icon,
    String text,
    double Function(double) rw,
    double Function(double) rfs,
  ) {
    return Row(
      children: [
        Icon(icon, size: rw(20), color: const Color(0xFF0097B2)),
        SizedBox(width: rw(5)),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: rfs(14),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
