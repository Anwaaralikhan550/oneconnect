import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartnerStep7Screen extends StatefulWidget {
  const PartnerStep7Screen({super.key});

  @override
  State<PartnerStep7Screen> createState() => _PartnerStep7ScreenState();
}

class _PartnerStep7ScreenState extends State<PartnerStep7Screen> {
  final List<Map<String, dynamic>> faqItems = [
    {
      'question': 'When will I receive my login credentials?',
      'answer': 'You will receive your login credentials via email within 24-48 hours after approval.',
      'isExpanded': false,
    },
    {
      'question': 'What happens next?',
      'answer': 'Our team will review your application and contact you with further instructions to complete your profile setup.',
      'isExpanded': false,
    },
  ];

  String get _businessId {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['businessId'] ?? '';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 352),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 25),
                          child: Column(
                            children: [
                              // Title
                              Container(
                                constraints: const BoxConstraints(maxWidth: 292),
                                padding: const EdgeInsets.only(bottom: 30),
                                child: const Text(
                                  'Congratulations your application has been processed',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    height: 1.21,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // Congratulations Image - NO SHADOW
                              SizedBox(
                                width: 260,
                                height: 260,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Image.asset(
                                    'assets/images/congratulations_step7.png',
                                    width: 260,
                                    height: 260,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to existing image if new one is not found
                                      return Image.asset(
                                        'assets/images/congratulations_illustration.png',
                                        width: 260,
                                        height: 260,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 260,
                                            height: 260,
                                            color: const Color(0xFFF0F0F0),
                                            child: const Icon(
                                              Icons.celebration,
                                              size: 100,
                                              color: Color(0xFF3499AF),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Business ID display
                              if (_businessId.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F9FB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF3499AF).withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Your Business ID',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6D758F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: SelectableText(
                                              _businessId,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF3499AF),
                                                letterSpacing: 1.0,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(text: _businessId),
                                              );
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Business ID copied')),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.copy_rounded,
                                              size: 20,
                                              color: Color(0xFF3499AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Save this ID — you will need it to log in',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFE74C3C),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                              // "Thank you for becoming a part of" text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: const Text(
                                  'Thank you for becoming a part of',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    height: 1.22,
                                    letterSpacing: -0.28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // OneConnect Logo
                              Container(
                                width: 280,
                                height: 65,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF000000).withOpacity( 0.12),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF424242).withOpacity( 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/images/oneconnect_logo_step7.svg',
                                      width: 260,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) {
                                        return Container(
                                          width: 260,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF000000).withOpacity( 0.12),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                                spreadRadius: 0,
                                              ),
                                              BoxShadow(
                                                color: const Color(0xFF424242).withOpacity( 0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'OneConnect',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF3499AF),
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // FAQ Section
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0x26000000),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            children: [
                              // FAQ Title
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFD0D0D0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Any questions?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      height: 1.21,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              // FAQ Items
                              ...faqItems.map((item) {
                                final isLast = faqItems.indexOf(item) == faqItems.length - 1;
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                                  decoration: BoxDecoration(
                                    border: isLast ? null : const Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFD0D0D0),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      childrenPadding: EdgeInsets.zero,
                                      title: Text(
                                        item['question'],
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      trailing: Icon(
                                        item['isExpanded'] ? Icons.expand_less : Icons.expand_more,
                                        color: Colors.black54,
                                      ),
                                      onExpansionChanged: (expanded) {
                                        setState(() {
                                          item['isExpanded'] = expanded;
                                        });
                                      },
                                      children: [
                                        const SizedBox(height: 8),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item['answer'],
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade600,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button Container
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3499AF), // Blue color matching other Figma buttons
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/partner-login',
                            (route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Center(
                          child: Text(
                            'Finish',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
