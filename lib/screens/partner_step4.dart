import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PartnerStep4Screen extends StatefulWidget {
  const PartnerStep4Screen({super.key});

  @override
  State<PartnerStep4Screen> createState() => _PartnerStep4ScreenState();
}

class _PartnerStep4ScreenState extends State<PartnerStep4Screen>
    with TickerProviderStateMixin {
  bool _preciseLocationEnabled = true;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pulse animation for location pin
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final padding = MediaQuery.of(context).padding;

    // Safe responsive calculations
    double scale = 1.0;
    double containerMaxWidth = 400.0;
    double modalMaxWidth = 320.0;

    // Calculate scale based on screen width with safe boundaries
    if (screenWidth <= 320) {
      scale = 0.8;
      containerMaxWidth = screenWidth * 0.95;
      modalMaxWidth = screenWidth * 0.90;
    } else if (screenWidth <= 375) {
      scale = 0.9;
      containerMaxWidth = screenWidth * 0.92;
      modalMaxWidth = screenWidth * 0.88;
    } else if (screenWidth <= 414) {
      scale = 1.0;
      containerMaxWidth = screenWidth * 0.90;
      modalMaxWidth = screenWidth * 0.85;
    } else if (screenWidth <= 768) {
      scale = 1.1;
      containerMaxWidth = 450.0;
      modalMaxWidth = 400.0;
    } else {
      scale = 1.2;
      containerMaxWidth = 500.0;
      modalMaxWidth = 450.0;
    }

    // Ensure minimum viable sizes
    final modalWidth = (270 * scale).clamp(280.0, modalMaxWidth);
    final mapHeight = (174 * scale).clamp(160.0, 200.0);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFFFFFFF),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: containerMaxWidth,
                          minHeight: (screenHeight - padding.top - padding.bottom) * 0.5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main permission modal
                            Container(
                              width: modalWidth,
                              constraints: BoxConstraints(
                                minWidth: 280.0,
                                maxWidth: modalMaxWidth,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity( 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity( 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header section
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // Location icon
                                          Container(
                                            width: 48,
                                            height: 48,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF007AFF),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF007AFF).withOpacity( 0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),

                                          // Title
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: modalWidth * 0.9,
                                            ),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              'Allow "OneConnect" to use your location?',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: (17 * scale).clamp(16.0, 20.0),
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1A202C),
                                                height: 1.3,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                          // Description
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: modalWidth * 0.95,
                                            ),
                                            child: Text(
                                              'Your precise location helps us show your position on the map and provide better directions.',
                                              style: TextStyle(
                                                fontFamily: 'SF Pro Text',
                                                fontSize: (13 * scale).clamp(12.0, 15.0),
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF64748B),
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Map section
                                    Container(
                                      width: modalWidth,
                                      height: mapHeight,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Map background
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Stack(
                                                  children: [
                                                    // Map image
                                                    Positioned(
                                                      left: -10,
                                                      top: -6,
                                                      child: SizedBox(
                                                        width: modalWidth + 20,
                                                        height: mapHeight + 12,
                                                        child: Image.asset(
                                                          'assets/images/map_view_step4.png',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              color: Colors.grey.shade300,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.map_outlined,
                                                                  size: 40,
                                                                  color: Colors.grey.shade600,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Precise switcher
                                          Positioned(
                                            left: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity( 0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.my_location,
                                                    size: 12,
                                                    color: const Color(0xFF007AFF),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Precise: On',
                                                    style: TextStyle(
                                                      fontFamily: 'SF Pro Text',
                                                      fontSize: (11 * scale).clamp(10.0, 13.0),
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF007AFF),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Location pin with animation
                                          Positioned(
                                            left: modalWidth * 0.5 - 7,
                                            top: mapHeight * 0.35,
                                            child: AnimatedBuilder(
                                              animation: _pulseAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _pulseAnimation.value,
                                                  child: Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF007AFF),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 3,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(0xFF007AFF).withOpacity( 0.4),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Options section
                                    SizedBox(
                                      width: modalWidth,
                                      child: Column(
                                        children: _buildOptions(modalWidth),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildOptions(double modalWidth) {
    final options = [
      {
        'text': 'Allow Once',
        'onTap': () => _navigateToNextStep(),
      },
      {
        'text': 'Allow While Using the App',
        'onTap': () {
          setState(() {
            _preciseLocationEnabled = true;
          });
          _navigateToNextStep();
        },
      },
      {
        'text': "Don't Allow",
        'onTap': () {
          setState(() {
            _preciseLocationEnabled = false;
          });
          _navigateToNextStep();
        },
      },
    ];

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isLast = index == options.length - 1;

      return Column(
        children: [
          // Separator
          if (index == 0)
            Container(
              width: modalWidth * 0.9,
              height: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFFE2E8F0),
            ),

          // Option button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: option['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: modalWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: Text(
                    option['text'] as String,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF007AFF),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Separator between options
          if (!isLast)
            Container(
              width: modalWidth * 0.9,
              height: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFE2E8F0),
            ),
        ],
      );
    }).toList();
  }

  void _navigateToNextStep() {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      Navigator.pushNamed(context, '/partner-step5', arguments: args);
    } catch (e) {
      // Fallback navigation
      debugPrint('Navigation error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/partner-step5');
      }
    }
  }
}
