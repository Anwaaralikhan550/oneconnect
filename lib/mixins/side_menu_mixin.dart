import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';

mixin SideMenuMixin on State, TickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  bool get isMenuOpen => _isMenuOpen;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
    _animationController.reverse();
  }

  Widget buildMenuButton() {
    return GestureDetector(
      onTap: toggleMenu,
      child: SizedBox(
        width: 33,
        height: 31,
        child: Stack(
          children: [
            // Hamburger lines
            Positioned(
              left: 1,
              top: 6,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: 14,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: 22,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Small circle
            Positioned(
              right: 1,
              top: 17,
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSideMenuOverlay() {
    return SideMenu(
      isOpen: _isMenuOpen,
      onClose: closeMenu,
      slideAnimation: _slideAnimation,
    );
  }
}