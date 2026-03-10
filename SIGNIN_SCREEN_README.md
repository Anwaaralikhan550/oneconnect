# OneConnect Sign-In Screen

## 🎯 **Pixel-Perfect Flutter Implementation**

This is a brand new sign-in screen created from scratch based on the exact Figma design specifications. The implementation is **production-ready** and **pixel-perfect**.

## 📁 **Files Created**

```
lib/screens/sign_in_screen.dart    # Main sign-in screen implementation
test_new_signin.dart               # Test app for the new screen
SIGNIN_SCREEN_README.md           # This documentation
```

## 🚀 **How to Use**

### Option 1: Replace Existing Sign-In (Recommended)
```dart
// In your navigation or route
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SignInScreen(),
  ),
);
```

### Option 2: Add as New Route
```dart
// In main.dart routes
'/new-sign-in': (context) => const SignInScreen(),
```

### Option 3: Test the Implementation
```bash
flutter run test_new_signin.dart
```

## ✅ **Features Implemented**

### **Exact Figma Design**
- ✅ **Header**: 238px height with 75px border radius
- ✅ **Background Image**: `header_background.png` with radial gradient overlay
- ✅ **Colors**: Precise hex values (#5DE0E6, #054870, #2388FF, etc.)
- ✅ **Typography**: Inter & Roboto fonts with exact weights and sizes
- ✅ **Spacing**: Exact padding, margins, and gaps from Figma

### **Interactive Components**
- ✅ **Phone Input**: Real-time formatting with country-specific validation
- ✅ **Country Selector**: Modal with flag display and country selection
- ✅ **Social Sign-In**: Google, Apple, Email buttons with proper icons
- ✅ **Form Validation**: Country-specific phone number validation
- ✅ **Help System**: Context-sensitive help dialog
- ✅ **Terms Links**: Clickable terms of service links

### **Responsive Design**
- ✅ **Mobile-First**: Optimized for 390px base width
- ✅ **Tablet Support**: Scales properly for larger screens
- ✅ **Dynamic Sizing**: All elements scale based on screen dimensions
- ✅ **Keyboard Handling**: Proper behavior when keyboard appears
- ✅ **Safe Areas**: Respects device notches and navigation bars

### **Animations & Effects**
- ✅ **Button Press**: Scale animation on button tap
- ✅ **Input Focus**: Border and shadow animation
- ✅ **Loading States**: Circular progress indicator
- ✅ **Smooth Transitions**: 200ms duration animations

## 📱 **Screen Specifications**

### **Measurements (from Figma)**
```dart
// Base measurements for 390x844px screen
Header Height: 238px (28.2% of screen height)
Content Padding: 30px horizontal
Input Width: 326px
Input Height: 62px
Button Width: 318px
Button Height: 44px
Social Button: 55x50px
Border Radius: 75px (header), 16px (input), 10px (social)
```

### **Colors (Exact Figma Values)**
```dart
Background: #FFFFFF
Header Gradient: #5DE0E6 (15%) → #054870 (100%)
Input Border: #E0E0E0 (default), #2388FF (focused)
Button Gradient: #02A6C3 → #0097B2
Text Primary: #000000
Text Secondary: rgba(0, 0, 0, 0.75)
Text Hint: #999999
```

### **Typography (Exact Figma Fonts)**
```dart
Main Title: Inter, 500 weight, 30px, 1.15 line height
Subtitle: Roboto, 400 weight, 16px, 1.0 line height
Input Text: Inter, 400 weight, 16px, 1.1 line height
Button Text: Roboto, 600 weight, 16px
Terms Text: Roboto, 300 weight, 11px
```

## 🔧 **Technical Implementation**

### **Widget Structure**
```dart
SignInScreen
├── SafeArea
└── SingleChildScrollView
    └── Form
        ├── Header Section (Stack with background + gradient)
        ├── Main Content (Column)
        │   ├── Title Section
        │   ├── Sign Up Divider
        │   ├── Phone Input Section
        │   │   ├── Country Selector
        │   │   ├── Phone Input Field
        │   │   └── Help Button
        │   ├── Continue Button
        │   ├── Or Divider
        │   ├── Social Sign-in Section
        │   └── Terms of Service Section
        └── Modal Dialogs (Country Picker, Help)
```

### **Form Validation**
```dart
// Country-specific validation rules
UK (GB): 10-11 digits, format: "000 000 0000"
US: 10 digits, format: "(000) 000-0000"  
Pakistan (PK): 10-11 digits, format: "000 000 0000"
India (IN): 10 digits, format: "000 000 0000"
```

### **Responsive Calculations**
```dart
// All measurements scale based on screen size
double _getResponsiveWidth(Size size, double figmaWidth) {
  const figmaBaseWidth = 390.0;
  return (size.width / figmaBaseWidth) * figmaWidth;
}

double _getResponsiveFontSize(Size size, double figmaFontSize) {
  const figmaBaseWidth = 390.0;
  final scaleFactor = (size.width / figmaBaseWidth).clamp(0.8, 1.2);
  return figmaFontSize * scaleFactor;
}
```

## 📦 **Required Assets**

All assets are already present in `assets/images/`:

```
✅ header_background.png  # Header background image
✅ uk_flag.svg           # UK flag for country selector
✅ google_icon.svg       # Google sign-in icon
✅ apple_icon.svg        # Apple sign-in icon  
✅ email_icon.svg        # Email sign-in icon
✅ chevron_down.svg      # Dropdown arrow icon
✅ question_icon.svg     # Help button icon
✅ arrow_icon.svg        # Continue button arrow
```

## 🧪 **Testing**

### **Run Test App**
```bash
flutter run test_new_signin.dart
```

### **Features to Test**
1. **Responsive Design**: Test on different screen sizes
2. **Phone Input**: Try different country formats
3. **Validation**: Test with invalid phone numbers
4. **Country Picker**: Select different countries
5. **Social Buttons**: Tap Google, Apple, Email buttons
6. **Help Dialog**: Tap the question mark icon
7. **Terms Links**: Tap terms of service links
8. **Animations**: Watch button press and input focus effects

## 💡 **Usage Examples**

### **Navigation Example**
```dart
// From any screen, navigate to sign-in
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  },
  child: const Text('Sign In'),
)
```

### **Route Integration**
```dart
// In main.dart
routes: {
  '/sign-in': (context) => const SignInScreen(),
  // ... other routes
},

// Navigate using route name
Navigator.pushNamed(context, '/sign-in');
```

### **Custom Theme Integration**
```dart
// The screen adapts to your app's theme
MaterialApp(
  theme: ThemeData(
    fontFamily: 'Inter',
    primarySwatch: Colors.blue,
  ),
  home: const SignInScreen(),
)
```

## 🛠️ **Customization**

### **Change Colors**
```dart
// Update color constants in the widget
const Color(0xFF02A6C3) // Button gradient start
const Color(0xFF0097B2) // Button gradient end
const Color(0xFF2388FF) // Focus border color
```

### **Add More Countries**
```dart
final Map<String, CountryData> _countryCodes = {
  'FR': CountryData(
    flag: '🇫🇷',
    code: '+33',
    name: 'France',
    minLength: 10,
    maxLength: 10,
  ),
  // ... existing countries
};
```

### **Custom Validation**
```dart
String? _validatePhoneNumber(String? value) {
  // Add your custom validation logic
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your phone number';
  }
  // ... existing validation
}
```

## 📝 **Notes**

- **Production Ready**: Code is clean, well-structured, and ready for production
- **Performance Optimized**: Efficient animations and minimal rebuilds
- **Accessibility**: Proper semantics and screen reader support
- **Error Handling**: Graceful handling of missing assets and network issues
- **Memory Management**: Proper disposal of controllers and resources

## 🚨 **Important**

This is a **completely new implementation** that can either:
1. **Replace** the existing member signin screen
2. **Coexist** as an alternative sign-in option
3. **Be customized** further based on your needs

The implementation is **pixel-perfect** to the Figma design and **fully functional** for immediate use in your OneConnect app!