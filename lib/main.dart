import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider_provider.dart';
import 'providers/business_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/property_provider.dart';
import 'providers/promotion_provider.dart';
import 'providers/review_provider.dart';
import 'providers/partner_provider.dart';
import 'providers/admin_office_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/location_provider.dart';
import 'utils/token_storage.dart';
import 'screens/splash_animation.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/member_signup_screen.dart';
import 'screens/email_password_signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/join_community_signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_screen_of_oneconnect.dart';
import 'screens/services_hub_screen.dart';
import 'screens/all_services_screen.dart';
import 'screens/service_provider_detail_screen.dart';
import 'screens/electricians_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/push_notification_settings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/laundry_screen.dart';
import 'screens/plumber_screen.dart';
import 'screens/water_screen.dart';
import 'screens/gas_screen.dart';
import 'screens/painter_screen.dart';
import 'screens/barber_screen.dart';
import 'screens/beauty_screen.dart';
import 'screens/maid_screen.dart';
import 'screens/carpenter_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/businesses_and_amenities_hub_screen.dart';
import 'screens/property_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/property_agent_screen.dart';
import 'screens/grocery_store_screen.dart';
import 'screens/stores_list_screen.dart';
import 'screens/solar_list_screen.dart';
import 'screens/bank_list_screen.dart';
import 'screens/restaurant_list_screen.dart';
import 'screens/home_chef_list_screen.dart';
import 'screens/park_list_screen.dart';
import 'screens/mosque_list_screen.dart';
import 'screens/healthcare_list_screen.dart';
import 'screens/gym_list_screen.dart';
import 'screens/school_list_screen.dart';
import 'screens/pharmacy_list_screen.dart';
import 'screens/cafe_list_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_detail_screen.dart';
import 'screens/slide_menu.dart';
import 'screens/partner_step1.dart';
import 'screens/partner_step2.dart';
import 'screens/partner_step3.dart';
import 'screens/partner_step4.dart';
import 'screens/partner_step5.dart';
import 'screens/partner_step6.dart';
import 'screens/partner_step7.dart';
import 'screens/partner_dashboard_screen.dart';
import 'screens/partner_login_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/partner_bookings_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for better UX
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for consistent appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Keep app boot resilient if Firebase is unavailable in local/dev setup.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProvider(create: (_) => AdminOfficeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..hydrateFavorites()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const OneConnectApp(),
    ),
  );
}

/// Global navigator key — used by ApiClient for session-expired redirect.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class OneConnectApp extends StatelessWidget {
  const OneConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'OneConnect',
      
      // ==================== THEME CONFIGURATION ====================
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.light, // Default to light theme for sign-in screens
      
      // ==================== APP CONFIGURATION ====================
      debugShowCheckedModeBanner: false,

      // Hot reload optimization - only enable performance overlays when needed
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      
      // ==================== NAVIGATION CONFIGURATION ====================
      initialRoute: '/splash',
      onGenerateInitialRoutes: (String initialRouteName) {
        return [
          MaterialPageRoute<void>(
            builder: (context) => const SplashAnimationScreen(),
            settings: const RouteSettings(name: '/splash'),
          ),
        ];
      },
      
      // ==================== ROUTES CONFIGURATION ====================
      routes: _buildRoutes(),
      
      // ==================== ERROR HANDLING ====================
      onGenerateRoute: _handleUnknownRoute,
      onUnknownRoute: _handleUnknownRoute,
      
      // ==================== PERFORMANCE OPTIMIZATIONS ====================
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  // ==================== THEME BUILDERS ====================
  
  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF0097B2);
    const secondaryColor = Color(0xFF02A6C3);
    const backgroundColor = Color(0xFFFFFFFF);
    const surfaceColor = Color(0xFFF8F9FA);
    const errorColor = Color(0xFFE74C3C);

    return ThemeData(
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        surfaceContainerHighest: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onError: Colors.white,
      ),

      // Primary Colors
      primarySwatch: _createMaterialColor(primaryColor),
      scaffoldBackgroundColor: backgroundColor,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Material 3 support
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF0097B2);
    const secondaryColor = Color(0xFF02A6C3);
    const backgroundColor = Color(0xFF121212);
    const surfaceColor = Color(0xFF1E1E1E);
    
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        surfaceContainerHighest: surfaceColor,
      ),
      primarySwatch: _createMaterialColor(primaryColor),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: _buildTextTheme(isDark: true),
      useMaterial3: true,
    );
  }

  TextTheme _buildTextTheme({bool isDark = false}) {
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black87;
    
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.15,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.2,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: subtitleColor,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: subtitleColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subtitleColor,
        height: 1.4,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  // ==================== ROUTES CONFIGURATION ====================
  
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/splash': (context) => const SplashAnimationScreen(),
      '/welcome': (context) => const WelcomeScreen(),
      '/signup': (context) => const SignupScreen(),
      '/member-signup': (context) => const SignUpMemberScreen(),
      '/member-account-details': (context) => const EmailPasswordSignupScreen(),
      '/email-password-signup': (context) => const EmailPasswordSignupScreen(),
      '/login': (context) => const LoginScreen(),
      '/sign-in': (context) => const LoginScreen(),
      '/join-community-signup': (context) => const JoinCommunitySignupScreen(),
      '/forgot-password': (context) => const ForgotPasswordScreen(),
      '/main-screen-of-oneconnect': (context) => const AuthRouteGate(
            requirePartner: false,
            child: MainScreenOfOneConnect(),
          ),
      '/services-hub': (context) => const ServicesHubScreen(),
      '/all-services': (context) => const AllServicesScreen(),
      '/electricians': (context) => const ElectriciansScreen(),
      '/edit-profile': (context) => const EditProfileScreen(),
      '/settings': (context) => const AuthRouteGate(
            requirePartner: false,
            child: SettingsScreen(),
          ),
      '/profile': (context) => const AuthRouteGate(
            requirePartner: false,
            child: ProfileScreen(),
          ),
      '/privacy': (context) => const PrivacyPolicyScreen(),
      '/privacy-policy': (context) => const PrivacyPolicyScreen(),
      '/terms-and-conditions': (context) => const TermsAndConditionsScreen(),
      '/about': (context) => const AboutAppScreen(),
      '/about-app': (context) => const AboutAppScreen(),
      '/faq': (context) => const FAQScreen(),
      '/push-notification-settings': (context) => const AuthRouteGate(
            requirePartner: false,
            child: PushNotificationSettingsScreen(),
          ),
      '/search': (context) => const SearchScreen(),
      // '/location-permission' handled in _handleUnknownRoute for transparent route
      '/notification': (context) => const AuthRouteGate(
            requirePartner: false,
            child: NotificationScreen(),
          ),
      '/home': (context) => const MainScreenOfOneConnect(),
      '/laundry': (context) => const LaundryScreen(),
      '/plumber': (context) => const PlumberScreen(),
      '/water': (context) => const WaterScreen(),
      '/gas': (context) => const GasScreen(),
      '/painter': (context) => const PainterScreen(),
      '/barber': (context) => const BarberScreen(),
      '/beauty': (context) => const BeautyScreen(),
      '/maid': (context) => const MaidScreen(),
      '/carpenter': (context) => const CarpenterScreen(),
      '/doctors': (context) => const DoctorsScreen(),
      '/businesses-hub': (context) => const BusinessesAndAmenitiesHubScreen(),
      '/stores': (context) => const StoresListScreen(),
      '/solar': (context) => const SolarListScreen(),
      '/banks': (context) => const BankListScreen(),
      '/restaurants': (context) => const RestaurantListScreen(),
      '/home-chefs': (context) => const HomeChefListScreen(),
      '/parks': (context) => const ParkListScreen(),
      '/mosques': (context) => const MosqueListScreen(),
      '/healthcare': (context) => const HealthcareListScreen(),
      '/gyms': (context) => const GymListScreen(),
      '/schools': (context) => const SchoolListScreen(),
      '/pharmacies': (context) => const PharmacyListScreen(),
      '/cafes': (context) => const CafeListScreen(),
      '/admin': (context) => const AdminScreen(),
      '/admin-detail': (context) => const AdminDetailScreen(),
      '/property': (context) => const PropertyScreen(),
      '/property-list': (context) => const PropertyScreen(),
      '/property-detail': (context) => const PropertyDetailScreen(),
      '/slide-menu': (context) => const SlideMenu(),
      '/partner-step1': (context) => const PartnerStep1Screen(),
      '/partner-step2': (context) => const PartnerStep2Screen(),
      '/partner-step3': (context) => const PartnerStep3Screen(),
      '/partner-step4': (context) => const PartnerStep4Screen(),
      '/partner-step5': (context) => const PartnerStep5Screen(),
      '/partner-step6': (context) => const PartnerStep6Screen(),
      '/partner-step7': (context) => const PartnerStep7Screen(),
      '/partner-dashboard': (context) => const AuthRouteGate(
            requirePartner: true,
            child: PartnerDashboardScreen(),
          ),
      '/partner-login': (context) => const PartnerLoginScreen(),
      '/my-bookings': (context) => const AuthRouteGate(
            requirePartner: false,
            child: MyBookingsScreen(),
          ),
      '/partner-bookings': (context) => const AuthRouteGate(
            requirePartner: true,
            child: PartnerBookingsScreen(),
          ),
    };
  }

  // ==================== ERROR HANDLING ====================
  
  Route<dynamic> _handleUnknownRoute(RouteSettings settings) {
    // Handle location permission with transparent background
    if (settings.name == '/location-permission') {
      return PageRouteBuilder<void>(
        settings: settings,
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LocationPermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    }

    // Handle search results route with arguments
    if (settings.name == '/search-results') {
      String query = '';
      Map<String, String>? initialFilterQueryParams;
      final args = settings.arguments;
      if (args is String) {
        query = args;
      } else if (args is Map) {
        query = (args['query']?.toString() ?? '').trim();
        final rawFilter = args['filter'];
        if (rawFilter is Map) {
          initialFilterQueryParams = rawFilter.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
        }
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => SearchResultsScreen(
          query: query,
          initialFilterQueryParams: initialFilterQueryParams,
        ),
      );
    }
    
    // Handle service provider detail route with arguments
    if (settings.name == '/service-provider-detail') {
      final Map<String, String>? args = settings.arguments as Map<String, String>?;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => ServiceProviderDetailScreen(
          providerName: args?['providerName'] ?? 'Service Provider',
          serviceType: args?['serviceType'] ?? 'Professional Service',
        ),
      );
    }

    // Handle grocery store route with arguments
    if (settings.name == '/grocery-store') {
      final Map<String, dynamic>? storeData = settings.arguments as Map<String, dynamic>?;
      final category = (storeData?['category']?.toString() ?? '').trim().toUpperCase();
      final isRealEstate = category == 'REAL_ESTATE' || category == 'REAL ESTATE';
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => isRealEstate
            ? PropertyScreen(
                partnerId: storeData?['partnerId']?.toString() ??
                    storeData?['partner']?['id']?.toString(),
              )
            : GroceryStoreScreen(storeData: storeData),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${settings.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UTILITY METHODS ====================
  
  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = (color.value >> 16) & 0xFF;
    final int g = (color.value >> 8) & 0xFF;
    final int b = color.value & 0xFF;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}

class AuthRouteGate extends StatelessWidget {
  final bool requirePartner;
  final Widget child;

  const AuthRouteGate({
    super.key,
    required this.requirePartner,
    required this.child,
  });

  Future<bool> _isAuthorized() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return false;
    final isPartner = await TokenStorage.isPartner();
    return requirePartner ? isPartner : !isPartner;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthorized(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) return child;
        return const _UnauthorizedRedirect();
      },
    );
  }
}

class _UnauthorizedRedirect extends StatefulWidget {
  const _UnauthorizedRedirect();

  @override
  State<_UnauthorizedRedirect> createState() => _UnauthorizedRedirectState();
}

class _UnauthorizedRedirectState extends State<_UnauthorizedRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
