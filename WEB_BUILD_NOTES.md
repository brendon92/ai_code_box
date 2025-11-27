# Web Build Limitations

## ⚠️ Important: Isar Database Not Compatible with Web

The current implementation uses **Isar** database, which relies on `dart:ffi` (Foreign Function Interface). This makes it **incompatible with web builds** because:

1. **WebAssembly Limitations**: `dart:ffi` cannot be used when compiling to WebAssembly/JavaScript
2. **Integer Precision**: Large integers in generated Isar files (`.g.dart`) cannot be represented exactly in JavaScript

## Current Build Status

### ✅ Fixed Issues
- Import paths (changed to package imports)
- Langchain API usage (using `ChatPromptValue` correctly)
- Agent name conflicts
- Icon issues

### ⚠️ Web Build Will Fail
- Isar database incompatibility (expected)
- Integer literal errors in `.g.dart` files (Isar-related)

## Recommended Build Targets

### ✅ Supported Platforms
- **Android** - Full support
- **iOS** - Full support  
- **Linux** - Full support
- **macOS** - Full support
- **Windows** - Full support

### ❌ Not Supported (Currently)
- **Web** - Requires alternative database solution

## Build Commands

```bash
# Android (Recommended for testing)
flutter build apk --debug

# iOS (macOS only)
flutter build ios --debug

# Linux
flutter build linux --debug

# macOS
flutter build macos --debug

# Windows
flutter build windows --debug

# Web (Will fail - Isar incompatibility)
flutter build web --release
```

## Future Web Support

To enable web builds, you would need to:

1. **Implement Conditional Database Selection**:
   ```dart
   import 'package:flutter/foundation.dart' show kIsWeb;
   
   if (kIsWeb) {
     // Use Hive, SharedPreferences, or IndexedDB
   } else {
     // Use Isar
   }
   ```

2. **Alternative Database Options for Web**:
   - **Hive** - NoSQL database that works on web
   - **SharedPreferences** - Simple key-value storage
   - **IndexedDB** - Browser-native database
   - **SQLite compiled to WASM** - More complex but powerful

3. **Abstract Database Layer**:
   - Create a database interface
   - Implement Isar for mobile/desktop
   - Implement web-compatible solution for web

## Current Status

The application is **fully functional** for mobile and desktop platforms. Web support requires additional architecture changes to support alternative database solutions.

