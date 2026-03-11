import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/token_storage.dart';

class SplashAnimationScreen extends StatefulWidget {
  const SplashAnimationScreen({super.key});

  @override
  State<SplashAnimationScreen> createState() => _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends State<SplashAnimationScreen>
    with TickerProviderStateMixin {

  // Animation Controllers for three water-like waves
  late AnimationController _wave1Controller; // Left to right, rising from bottom
  late AnimationController _wave2Controller; // Right to left, rising from bottom
  late AnimationController _wave3Controller; // Left to right, rising from bottom
  late AnimationController _fillController;  // Bottom to top filling

  // Wave Animations
  late Animation<double> _wave1Animation;
  late Animation<double> _wave2Animation;
  late Animation<double> _wave3Animation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Wave 1: Left to right flow, rising from bottom left
    _wave1Controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Smooth wave motion
      vsync: this,
    );

    // Wave 2: Right to left flow, rising from bottom right
    _wave2Controller = AnimationController(
      duration: const Duration(milliseconds: 2600), // Different speed for natural effect
      vsync: this,
    );

    // Wave 3: Left to right flow, rising from bottom center
    _wave3Controller = AnimationController(
      duration: const Duration(milliseconds: 3200), // Slowest for depth
      vsync: this,
    );

    // Bottom to top filling controller
    _fillController = AnimationController(
      duration: const Duration(milliseconds: 4000), // 4 seconds to fill from bottom to top
      vsync: this,
    );

    // Wave 1: Horizontal left-to-right motion
    _wave1Animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _wave1Controller,
      curve: Curves.linear,
    ));

    // Wave 2: Horizontal right-to-left motion (negative for opposite direction)
    _wave2Animation = Tween<double>(
      begin: 0.0,
      end: -2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _wave2Controller,
      curve: Curves.linear,
    ));

    // Wave 3: Horizontal left-to-right motion (same direction as wave 1)
    _wave3Animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _wave3Controller,
      curve: Curves.linear,
    ));

    // Bottom to top fill animation
    _fillAnimation = Tween<double>(
      begin: 0.0, // Start from bottom (0% filled)
      end: 1.0,   // Rise to top (100% filled)
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    ));

  }

  void _startAnimationSequence() async {
    // Start waves with staggered timing from different positions
    _wave1Controller.repeat(); // First wave starts immediately

    await Future.delayed(const Duration(milliseconds: 200));
    _wave2Controller.repeat(); // Second wave (opposite direction)

    await Future.delayed(const Duration(milliseconds: 400));
    _wave3Controller.repeat(); // Third wave for depth

    // Start bottom-to-top filling
    _fillController.forward();

    // Wait exactly 4 seconds for animation to complete
    await Future.delayed(const Duration(milliseconds: 4000));

    if (mounted) {
      await _navigateBasedOnAuth();
    }
  }

  Future<void> _navigateBasedOnAuth() async {
    if (!mounted) return;

    final isLoggedIn = await TokenStorage.isLoggedIn();
    final rememberMe = await TokenStorage.getRememberMe();

    if (!mounted) return;

    if (isLoggedIn && rememberMe) {
      final isPartner = await TokenStorage.isPartner();
      if (!mounted) return;
      final route = isPartner ? '/partner-dashboard' : '/main-screen-of-oneconnect';
      Navigator.pushReplacementNamed(context, route);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  void dispose() {
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _wave3Controller.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Responsive circle size - matches Figma design proportions
    final circleSize = math.min(screenSize.width, screenSize.height) * 0.7;

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        // Clean gradient background matching Figma
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF), // Pure white
              Color(0xFFFFFDF8), // Warm white
              Color(0xFFFFF8F0), // Subtle cream
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Centered Circle with Water-Like Wave Animation
            Center(
              child: SizedBox(
                width: circleSize,
                height: circleSize,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _wave1Controller,
                    _wave2Controller,
                    _wave3Controller,
                    _fillController
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WaterWavePainter(
                        wave1Value: _wave1Animation.value,
                        wave2Value: _wave2Animation.value,
                        wave3Value: _wave3Animation.value,
                        fillValue: _fillAnimation.value,
                        circleSize: circleSize,
                      ),
                      size: Size(circleSize, circleSize),
                    );
                  },
                ),
              ),
            ),

            // Tap to skip functionality
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    _navigateBasedOnAuth();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double wave1Value;  // Left to right from bottom left
  final double wave2Value;  // Right to left from bottom right
  final double wave3Value;  // Left to right from bottom center
  final double fillValue;   // Bottom to top fill progress (0.0 to 1.0)
  final double circleSize;

  WaterWavePainter({
    required this.wave1Value,
    required this.wave2Value,
    required this.wave3Value,
    required this.fillValue,
    required this.circleSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = circleSize / 2;

    // Draw circle background with exact Figma color
    final circlePaint = Paint()
      ..color = const Color(0xFFFFF3C4) // Exact Figma background color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    // Create circular clipping path
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.clipPath(clipPath);

    // Calculate water level rising from bottom to top
    final waterHeight = radius * 2 * fillValue; // How much water has risen
    final waterTop = center.dy + radius - waterHeight; // Top of water surface

    // Only draw water if there's something to show
    if (fillValue > 0.0) {
      // Create water surface path with three curved waves
      final waterPath = Path();

      // Enhanced wave parameters for water-like motion
      final wave1Amplitude = 18.0; // Strong primary wave
      final wave2Amplitude = 14.0; // Medium counter wave
      final wave3Amplitude = 12.0; // Subtle depth wave

      final wave1Frequency = 1.2; // Broad waves for natural look
      final wave2Frequency = 1.8; // Medium frequency for interference
      final wave3Frequency = 0.8; // Long slow waves for depth

      final wave1Length = size.width / wave1Frequency;
      final wave2Length = size.width / wave2Frequency;
      final wave3Length = size.width / wave3Frequency;

      // Start water path from bottom left
      waterPath.moveTo(0, size.height);

      // Create water surface with three rising waves
      for (double x = 0; x <= size.width; x += 0.2) {
        // Wave 1: Left to right from bottom left position
        final wave1Phase = (x / wave1Length * 2 * math.pi) + wave1Value;
        final wave1Height = math.sin(wave1Phase) * wave1Amplitude;

        // Add rising motion from bottom left
        final wave1Rise = math.sin((x / size.width + fillValue) * math.pi) * 4.0;

        // Wave 2: Right to left from bottom right position
        final wave2Phase = ((size.width - x) / wave2Length * 2 * math.pi) + wave2Value.abs();
        final wave2Height = math.sin(wave2Phase) * wave2Amplitude * 0.8;

        // Add rising motion from bottom right
        final wave2Rise = math.sin(((size.width - x) / size.width + fillValue) * math.pi) * 3.0;

        // Wave 3: Left to right from bottom center position
        final wave3Phase = ((x - size.width/2).abs() / wave3Length * 2 * math.pi) + wave3Value;
        final wave3Height = math.sin(wave3Phase) * wave3Amplitude * 0.9;

        // Add rising motion from bottom center
        final wave3Rise = math.sin((math.cos(x / size.width * math.pi) + fillValue) * math.pi) * 2.5;

        // Combine all wave effects
        final totalWaveHeight = wave1Height + wave2Height + wave3Height;
        final totalRise = wave1Rise + wave2Rise + wave3Rise;

        // Add natural water movement variations
        final naturalVariation = math.sin(x / size.width * math.pi * 2) * 2.0 * fillValue;
        final flowEffect = math.cos((wave1Value + wave3Value) * 0.4) * 1.5;

        final surfaceY = waterTop + totalWaveHeight + totalRise + naturalVariation + flowEffect;

        if (x == 0) {
          waterPath.moveTo(x, surfaceY);
        } else {
          waterPath.lineTo(x, surfaceY);
        }
      }

      // Complete water shape by connecting to bottom
      waterPath.lineTo(size.width, size.height);
      waterPath.lineTo(0, size.height);
      waterPath.close();

      // Enhanced water gradient that changes with fill level
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE98F).withOpacity( 0.85 + (0.15 * fillValue)), // Surface
            const Color(0xFFFFDE59).withOpacity( 0.92 + (0.08 * fillValue)), // Mid-water
            const Color(0xFFFFD700).withOpacity( 0.96 + (0.04 * fillValue)), // Deep water
            const Color(0xFFFFCC00).withOpacity( 1.0), // Bottom
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(0, waterTop, size.width, size.height - waterTop))
        ..style = PaintingStyle.fill;

      canvas.drawPath(waterPath, waterPaint);

      // Add realistic water highlights that follow waves
      final highlightIntensity = 0.2 + (0.2 * fillValue);
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity( highlightIntensity),
            Colors.white.withOpacity( highlightIntensity * 0.7),
            Colors.white.withOpacity( highlightIntensity * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, waterTop, size.width, size.height - waterTop))
        ..style = PaintingStyle.fill;

      // Create highlight path following primary wave
      final highlightPath = Path();
      highlightPath.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 1.0) {
        final wave1Phase = (x / wave1Length * 2 * math.pi) + wave1Value;
        final highlightOffset = math.sin(wave1Phase) * wave1Amplitude * 0.6;

        // Add shimmer effect that moves with the waves
        final shimmer = math.sin(x / size.width * 8 * math.pi + wave1Value * 3) * 2.0;

        final y = waterTop + highlightOffset + shimmer - 5;

        if (x == 0) {
          highlightPath.moveTo(x, y);
        } else {
          highlightPath.lineTo(x, y);
        }
      }

      highlightPath.lineTo(size.width, size.height);
      highlightPath.lineTo(0, size.height);
      highlightPath.close();

      canvas.drawPath(highlightPath, highlightPaint);
    }

    // Circle border with glow effect
    final borderPaint = Paint()
      ..color = const Color(0xFFFFDE59).withOpacity( 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) {
    return oldDelegate.wave1Value != wave1Value ||
           oldDelegate.wave2Value != wave2Value ||
           oldDelegate.wave3Value != wave3Value ||
           oldDelegate.fillValue != fillValue;
  }
}

