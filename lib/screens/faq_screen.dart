import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_constants.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // Responsive helpers
  double _rw(BuildContext context, double d) =>
      (MediaQuery.of(context).size.width / 390) * d;
  double _rh(BuildContext context, double d) =>
      (MediaQuery.of(context).size.height / 844) * d;
  double _rf(BuildContext context, double d) =>
      (MediaQuery.of(context).size.width / 390) * d;

  // Track expanded state for each FAQ
  final Map<int, bool> _expandedState = {};

  // FAQ data — sourced from centralized constants
  final List<Map<String, String>> _faqs = AppConstants.faqItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header (matches service_provider_detail_screen style)
              Container(
                width: double.infinity,
                height: _rh(context, 150),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(_rw(context, 50)),
                    bottomRight: Radius.circular(_rw(context, 50)),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _rw(context, 15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: _rw(context, 35),
                            height: _rw(context, 35),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3195AB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: _rw(context, 18),
                            ),
                          ),
                        ),
                        SizedBox(width: _rw(context, 15)),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              'FAQ',
                              style: GoogleFonts.inter(
                                fontSize: _rf(context, 20),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF515151),
                                letterSpacing: -0.28,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(width: _rw(context, 15)),
                        // Right placeholder (kept empty for symmetry)
                        SizedBox(
                          width: _rw(context, 35),
                          height: _rw(context, 35),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rw(context, 18),
                    vertical: _rh(context, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main title
                      Center(
                        child: Text(
                          'Frequently Asked Questions',
                          style: GoogleFonts.inter(
                            fontSize: _rf(context, 24),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF000000),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: _rh(context, 24)),

                      // FAQ List
                      ..._faqs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final faq = entry.value;
                        return _buildFAQItem(context, faq, index);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top centered decorative icon (faq.svg)
          Positioned(
            left: 0,
            right: 0,
            top: _rh(context, 130),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/faq.svg',
                width: _rw(context, 30),
                height: _rw(context, 30),
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFC107),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, Map<String, String> faq, int index) {
    final isExpanded = _expandedState[index] ?? false;
    
    return Container(
      margin: EdgeInsets.only(bottom: _rh(context, 1)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedState[index] = expanded;
            });
          },
          tilePadding: EdgeInsets.symmetric(
            vertical: _rh(context, 12),
            horizontal: 0,
          ),
          childrenPadding: EdgeInsets.only(
            bottom: _rh(context, 16),
            left: 0,
            right: 0,
          ),
          title: Text(
            faq['question']!,
            style: GoogleFonts.inter(
              fontSize: _rf(context, 16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000000),
              height: 1.3,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xFF000000),
            size: _rf(context, 20),
          ),
          children: [
            Text(
              faq['answer']!,
              style: GoogleFonts.inter(
                fontSize: _rf(context, 14),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

