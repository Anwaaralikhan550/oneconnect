import 'package:flutter/material.dart';
import 'side_menu.dart';

class SideMenuController {
  bool _isMenuOpen = false;
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;
  bool _isInitialized = false;

  bool get isMenuOpen => _isMenuOpen;
  bool get isInitialized => _isInitialized;

  void initialize(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _isInitialized = true;
  }

  void dispose() {
    _animationController?.dispose();
  }

  void toggleMenu(VoidCallback setState) {
    if (!_isInitialized) return;
    _isMenuOpen = !_isMenuOpen;
    setState();
    if (_isMenuOpen) {
      _animationController?.forward();
    } else {
      _animationController?.reverse();
    }
  }

  void closeMenu(VoidCallback setState) {
    if (!_isInitialized) return;
    _isMenuOpen = false;
    setState();
    _animationController?.reverse();
  }

  Widget buildMenuButton(VoidCallback setState) {
    return GestureDetector(
      onTap: _isInitialized ? () => toggleMenu(setState) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 36,
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Top line - white
            Positioned(
              left: 0,
              top: 4,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Middle line - yellow/gold
            Positioned(
              left: 0,
              top: 13,
              child: Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Yellow dot at end of middle line
            Positioned(
              left: 26,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Bottom line - white
            Positioned(
              left: 0,
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
          ],
        ),
      ),
    );
  }

  Widget buildSideMenuOverlay(VoidCallback setState) {
    if (!_isInitialized || _slideAnimation == null) {
      return const SizedBox.shrink();
    }
    return SideMenu(
      isOpen: _isMenuOpen,
      onClose: () => closeMenu(setState),
      slideAnimation: _slideAnimation!,
    );
  }
}