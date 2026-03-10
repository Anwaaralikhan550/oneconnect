import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Animation<double> slideAnimation;

  const SideMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.slideAnimation,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Calculate responsive scale based on design width (390px is standard mobile)
    final designWidth = 390.0;
    final scale = (screenWidth / designWidth).clamp(0.85, 1.3);
    
    // Responsive values
    final menuWidth = 595.0 * scale;
    final leftPadding = 20.0 * scale;
    final topPadding = 23.0 * scale;
    
    return AnimatedBuilder(
      animation: widget.slideAnimation,
      builder: (context, child) {
        // Only show overlay when menu is opening/closing or open
        if (widget.slideAnimation.value == 0.0 && !widget.isOpen) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Stack(
            children: [
              // Background overlay with animation
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.3 * widget.slideAnimation.value),
                ),
              ),

              // Side menu panel - slides from LEFT
              Transform.translate(
                offset: Offset(
                  -menuWidth + (menuWidth * widget.slideAnimation.value),
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00879F),
                    ),
                    child: Stack(
                      children: [
                        // Close button
                        Positioned(
                          left: leftPadding,
                          top: topPadding,
                          child: GestureDetector(
                            onTap: widget.onClose,
                            child: SizedBox(
                              width: 53 * scale,
                              height: 40 * scale,
                              child: SvgPicture.asset(
                                'assets/images/close_button.svg',
                                width: 53 * scale,
                                height: 40 * scale,
                                fit: BoxFit.contain,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Title
                        Positioned(
                          left: leftPadding,
                          top: 67 * scale,
                          child: SizedBox(
                            width: 270 * scale,
                            height: 50 * scale,
                            child: Text(
                              'Which service are you looking for today',
                              style: TextStyle(
                                fontFamily: 'Afacad',
                                fontWeight: FontWeight.w500,
                                fontSize: 25 * scale,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),

                        // Search bar - white color as shown in image
                        Positioned(
                          left: leftPadding,
                          top: 127 * scale,
                          right: leftPadding,
                          child: Container(
                            height: 48 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25 * scale),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 16 * scale),
                                Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 22 * scale,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15 * scale,
                                      fontFamily: 'Afacad',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15 * scale,
                                        fontFamily: 'Afacad',
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16 * scale),
                              ],
                            ),
                          ),
                        ),

                        // Service items positioned exactly as in Figma
                        // Starting at y:182 for first service (Laundry)
                        Positioned(
                          left: leftPadding,
                          top: 190 * scale,
                          child: _buildSimpleServiceItem(context, 'Laundry', Icons.local_laundry_service, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 247 * scale,
                          child: _buildSimpleServiceItem(context, 'Electrician', Icons.electrical_services, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 302 * scale,
                          child: _buildSimpleServiceItem(context, 'Plumber', Icons.plumbing, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 359 * scale,
                          child: _buildSimpleServiceItem(context, 'Painter', Icons.format_paint, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 416 * scale,
                          child: _buildSimpleServiceItem(context, 'Barber', Icons.content_cut, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 473 * scale,
                          child: _buildSimpleServiceItem(context, 'Beauty', Icons.face, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 530 * scale,
                          child: _buildSimpleServiceItem(context, 'Maid', Icons.cleaning_services, scale),
                        ),

                        Positioned(
                          left: leftPadding,
                          top: 587 * scale,
                          child: _buildSimpleServiceItem(context, 'Carpenter', Icons.handyman, scale),
                        ),

                        // See all services
                        Positioned(
                          left: leftPadding,
                          top: 655 * scale,
                          child: GestureDetector(
                            onTap: () {
                              widget.onClose();
                              Navigator.pushNamed(context, '/services-hub');
                            },
                            child: Text(
                              'See all services',
                              style: TextStyle(
                                fontFamily: 'Afacad',
                                fontWeight: FontWeight.w700,
                                fontSize: 16 * scale,
                                color: const Color(0xFFFFDE59),
                                height: 1.33,
                              ),
                            ),
                          ),
                        ),

                        // Preview container
                        Positioned(
                            top: 230 * scale,
                            right: 0,
                            child: Container(
                                width: 130 * scale,
                                height: 460 * scale,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.35),
                                  borderRadius: BorderRadius.circular(20 * scale),
                                ),
                            )),
                        
                        // Preview image
                        Positioned(
                            top: 210 * scale,
                            right: 0,
                            child: Image.asset(
                              "assets/images/dddd.png",
                              width: 100 * scale,
                              height: 500 * scale,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToService(BuildContext context, String serviceName) {
    String route;
    switch (serviceName.toLowerCase()) {
      case 'laundry':
        route = '/laundry';
        break;
      case 'electrician':
        route = '/electricians';
        break;
      case 'plumber':
        route = '/plumber';
        break;
      case 'painter':
        route = '/painter';
        break;
      case 'barber':
        route = '/barber';
        break;
      case 'beauty':
        route = '/beauty';
        break;
      case 'maid':
        route = '/maid';
        break;
      case 'carpenter':
        route = '/carpenter';
        break;
      default:
        route = '/all-services';
    }
    Navigator.pushNamed(context, route);
  }

  Widget _buildSimpleServiceItem(BuildContext context, String serviceName, IconData icon, double scale) {
    return GestureDetector(
      onTap: () {
        widget.onClose();
        _navigateToService(context, serviceName);
      },
      child: Row(
        children: [
          // Service icon
          SizedBox(
            width: 35 * scale,
            height: 35 * scale,
            child: Icon(
              icon,
              color: Colors.white,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 11 * scale),
          // Service text
          Text(
            serviceName,
            style: TextStyle(
              fontFamily: 'Afacad',
              fontWeight: FontWeight.w700,
              fontSize: 16 * scale,
              color: Colors.white,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}