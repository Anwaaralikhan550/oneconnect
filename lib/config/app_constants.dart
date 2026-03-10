/// Centralized constants extracted from screens.
/// Keeps hardcoded data in one place for easy updates.
class AppConstants {
  AppConstants._();

  // ── Contact info ───────────────────────────────────────────
  static const String defaultPhoneNumber = '+92 300 1234567';
  static const String supportEmail = 'support@oneconnect.pk';
  static const String supportHours = 'Mon-Sat, 9AM-6PM';
  static const String placeholderAddress = 'Address not available';

  // ── FAQ items ──────────────────────────────────────────────
  static const List<Map<String, String>> faqItems = [
    {
      'question': 'How do I register on OneConnect?',
      'answer':
          'To register on OneConnect, simply download the app and click on the "Sign Up" button. You can register using your phone number or email address. Follow the on-screen instructions to complete your profile and start using the app.',
    },
    {
      'question': 'How can businesses benefit from OneConnect?',
      'answer':
          'OneConnect helps businesses reach more customers by listing their services on our platform. Businesses can create profiles, showcase their work, receive bookings, and manage customer reviews. It\'s a great way to grow your customer base and increase visibility.',
    },
    {
      'question': 'What makes OneConnect different from other apps',
      'answer':
          'OneConnect offers a comprehensive platform that connects customers with verified service providers. We focus on quality, reliability, and user experience. Our app features detailed provider profiles, customer reviews, easy booking, and secure payment options.',
    },
    {
      'question': 'Is OneConnect free to use?',
      'answer':
          'Yes, OneConnect is free to download and use for customers. You can browse services, view provider profiles, read reviews, and book services without any charges. Service providers may have their own pricing for the services they offer.',
    },
    {
      'question': 'What services can I find on OneConnect?',
      'answer':
          'OneConnect offers a wide range of services including electricians, plumbers, carpenters, painters, barbers, beauty services, maids, laundry services, property listings, and many more. You can browse all available services in the services section of the app.',
    },
    {
      'question': 'Can I book or order directly through the app?',
      'answer':
          'Yes, you can book services directly through the OneConnect app. Simply browse the service you need, select a provider, and use the booking feature to schedule your service. You can also contact providers directly through the app.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can contact our support team through the "Contact us" option in your profile settings. We are available to help you with any questions, issues, or feedback. You can also reach out via email or through the in-app messaging system.',
    },
  ];

  // ── Doctor specialties ─────────────────────────────────────
  static const List<String> doctorSpecialtyTabs = [
    'All',
    'General Physician',
    'Pediatric',
    'gynecologist',
    'Cardiac',
    'Dentist',
    'Psychologist',
    'Physiotherapist',
    'ENT',
  ];

  // ── All services grid (all_services_screen) ────────────────
  static const List<Map<String, String>> allServicesGrid = [
    {'icon': 'assets/images/laundry_icon.svg', 'label': 'Laundry'},
    {'icon': 'assets/images/plumber_icon.svg', 'label': 'Plumber'},
    {'icon': 'assets/images/electrician_icon.svg', 'label': 'Electrician'},
    {'icon': 'assets/images/painter_icon.svg', 'label': 'Painter'},
    {'icon': 'assets/images/carpenter_icon.svg', 'label': 'Carpenter'},
    {'icon': 'assets/images/barber_icon.svg', 'label': 'Barber'},
    {'icon': 'assets/images/maid_icon.svg', 'label': 'Maid'},
    {'icon': 'assets/images/salon_icon.svg', 'label': 'Salon'},
    {'icon': 'assets/images/real_estate_icon.svg', 'label': 'Real Estate'},
    {'icon': 'assets/images/health_icon.svg', 'label': 'Health'},
    {'icon': 'assets/images/water_icon.svg', 'label': 'Water'},
    {'icon': 'assets/images/gas_icon.svg', 'label': 'Gas'},
  ];

  // ── Services filter categories (services_hub_screen) ───────
  static const List<String> serviceFilterCategories = [
    'All',
    'Laundry',
    'Plumber',
    'Electrician',
    'Painter',
    'Cleaning',
  ];
}
