# Hot Reload Guide for OneConnect

## Hot Reload is Now Configured! ✅

Your Flutter project has been optimized for instant hot reload during development.

## Quick Start

### Running the app with hot reload enabled:
```bash
# Start the app in debug mode (hot reload enabled by default)
flutter run

# Or run on a specific device
flutter run -d <device-id>

# Check connected devices
flutter devices
```

### Using Hot Reload:

1. **Hot Reload (r)**: Press `r` in the terminal or save your file
   - Updates UI instantly
   - Preserves app state
   - Works for most UI changes

2. **Hot Restart (R)**: Press `R` in the terminal or `Ctrl+Shift+F5` in VS Code
   - Restarts the app completely
   - Resets app state
   - Use when hot reload doesn't work

3. **Quit (q)**: Press `q` to stop the app

## What Changes Require Hot Reload vs Hot Restart?

### ✅ Hot Reload Works For:
- UI changes (widgets, layouts, colors, text)
- Adding or removing widgets
- Modifying widget properties
- Changing const values
- Function implementations
- Asset changes (after rebuild)

### 🔄 Hot Restart Required For:
- Changes to `main()` function
- Changes to global variables
- Adding new imports
- Modifying app initialization code
- Firebase configuration changes
- Native code changes (requires full rebuild)
- Changes to const constructors becoming non-const

## Optimizations Applied

### 1. **main.dart Configuration**
- Disabled unnecessary performance overlays
- Optimized hot reload detection
- Clean navigation structure

### 2. **Android Build Configuration**
- Debug build optimizations enabled
- Minification disabled for debug
- Resource shrinking disabled for debug

### 3. **Project Structure**
- Clean build cache
- Updated dependencies
- Proper const usage for performance

## Troubleshooting Hot Reload Issues

### Issue: Changes not reflecting after hot reload

**Solution 1**: Try hot restart instead
```bash
# Press R in terminal or Ctrl+Shift+F5 in VS Code
```

**Solution 2**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

**Solution 3**: Check for const constructors
- Remove `const` keyword if you need to modify that widget frequently
- Example: `const Text('Hello')` → `Text('Hello')`

### Issue: Hot reload very slow

**Solution 1**: Close unnecessary background apps

**Solution 2**: Check your device/emulator performance

**Solution 3**: Reduce widget rebuilds by using `const` where possible
```dart
// Good - widget won't rebuild unnecessarily
const Text('Static text')

// Better for dynamic content
Text(dynamicVariable)
```

### Issue: "Hot reload not supported" message

**Solutions**:
1. Check if you modified `main()` - requires hot restart
2. Ensure you're running in debug mode, not release
3. Make sure the app is still running

## Best Practices for Fast Development

### 1. Use Hot Reload for UI iteration
```dart
// Example: Quickly iterate on UI changes
Container(
  color: Colors.blue, // Change to Colors.red and press 'r'
  child: Text('Hello'), // Update text and press 'r'
)
```

### 2. Use `const` for static widgets
```dart
// Prevents unnecessary rebuilds
const SizedBox(height: 16),
const Divider(),
const Icon(Icons.home),
```

### 3. Extract widgets to enable hot reload
```dart
// Instead of inline widgets, extract them
class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Hot reload works better with extracted widgets
    );
  }
}
```

### 4. Avoid modifying these during hot reload:
- Global state initialization
- Firebase initialization
- Permission requests in `main()`
- Native platform code

## VS Code Shortcuts

- **Hot Reload**: `Ctrl+S` (save file) or `Ctrl+F5`
- **Hot Restart**: `Ctrl+Shift+F5`
- **Stop**: `Shift+F5`
- **Run**: `F5`

## Android Studio / IntelliJ Shortcuts

- **Hot Reload**: `Ctrl+\` or click ⚡ icon
- **Hot Restart**: Click 🔄 icon
- **Stop**: Click ⬛ icon

## Command Line Usage

```bash
# While app is running, press:
r  # Hot reload
R  # Hot restart
h  # List all available commands
q  # Quit
d  # Detach (keep app running)
```

## Performance Tips

### Keep Hot Reload Fast:
1. **Minimize const removals**: Keep const where possible
2. **Extract large widget trees**: Break into smaller widgets
3. **Use keys wisely**: Add keys only when necessary
4. **Avoid main() changes**: Test initialization separately
5. **Clean build occasionally**: Run `flutter clean` weekly

### If hot reload becomes slow over time:
```bash
# Clean and restart
flutter clean
flutter pub get
flutter run
```

## Common Scenarios

### Scenario: Adding a new screen
1. Create the new screen file
2. Import it in `main.dart` ← Requires hot **restart**
3. Add route configuration ← Requires hot **restart**
4. Modify UI elements ← Hot **reload** works

### Scenario: Changing colors/styles
1. Modify color values
2. Press `r` for hot reload ← Instant update!

### Scenario: Adding Firebase features
1. Add Firebase code
2. Initialize in `main()` ← Requires hot **restart**
3. Use Firebase in widgets ← Hot **reload** works after restart

## Debug Mode Benefits

The project is now configured to maximize hot reload performance in debug mode:

✅ Fast compilation
✅ State preservation
✅ Instant UI updates
✅ No minification delays
✅ Full debugging support

## Need Help?

- Hot reload documentation: https://docs.flutter.dev/development/tools/hot-reload
- Flutter debugging: https://docs.flutter.dev/testing/debugging
- Performance best practices: https://docs.flutter.dev/perf

---

**Remember**: Always run in debug mode (`flutter run`) for hot reload. Release mode (`flutter run --release`) doesn't support hot reload!
