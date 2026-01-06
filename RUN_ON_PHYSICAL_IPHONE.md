# How to Run on Physical iPhone

## ⚠️ CRITICAL: Debug Mode Issue

The app **crashes in DEBUG mode** on physical iPhones due to a Flutter 3.32.x engine bug with memory protection on iOS ARM64 devices.

**Solution**: Use **PROFILE** or **RELEASE** mode instead.

---

## Method 1: Run in Profile Mode (RECOMMENDED)

Profile mode gives you performance profiling while running on a real device:

```bash
cd /Users/macbook/Desktop/nahj/nahj_app
flutter run --profile
```

✅ This should work without crashing!

---

## Method 2: Run in Release Mode

For the best performance:

```bash
cd /Users/macbook/Desktop/nahj/nahj_app
flutter run --release
```

✅ This should also work!

---

## Method 3: Install via Xcode (RECOMMENDED FOR TESTING)

1. **Build the app:**
   ```bash
   cd /Users/macbook/Desktop/nahj/nahj_app
   flutter build ios --release
   ```

2. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **In Xcode:**
   - Connect your iPhone via USB
   - Select your iPhone from the device dropdown (top bar)
   - Select **Product > Scheme > Runner (Release)** or **Runner (Profile)**
   - Click the Run button (▶️)
   - You may need to sign the app with your Apple ID:
     - Click on "Runner" in the left panel
     - Go to "Signing & Capabilities" tab
     - Check "Automatically manage signing"
     - Select your Team/Apple ID

4. **First time on device:**
   - Go to iPhone Settings > General > VPN & Device Management
   - Trust your developer certificate

---

## Method 4: TestFlight (Production)

For distributing to users:

1. **Build archive:**
   - Open Xcode: `open ios/Runner.xcworkspace`
   - Product > Archive
   
2. **Upload to App Store Connect**

3. **Distribute via TestFlight**

---

## Why This Happens

The crash occurs due to:
- Flutter engine bug in version 3.32.x
- iOS's strict memory protection on ARM64 devices
- Issue: `Unable to flip between RX and RW memory protection on pages`
- Only affects **DEBUG** mode, not PROFILE or RELEASE

### Technical Details:
```
../../../flutter/third_party/dart/runtime/vm/virtual_memory_posix.cc: 254
error: Unable to flip between RX and RW memory protection on pages
```

This is a Dart VM issue when running in debug mode on physical iOS devices.

---

## Recommended Development Workflow

1. **Develop on iOS Simulator** (debug mode works fine):
   ```bash
   flutter run
   ```

2. **Test on physical device in profile mode**:
   ```bash
   flutter run --profile
   ```

3. **Final testing in release mode**:
   ```bash
   flutter run --release
   ```

---

## Quick Test Commands

```bash
# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..

# Run in profile mode (BEST FOR TESTING)
flutter run --profile

# Or run in release mode
flutter run --release
```

---

## Expected Behavior

✅ App starts immediately without hanging
✅ Main menu appears (خطب and رسائل buttons)
✅ Smooth navigation
✅ Theme follows system dark/light mode automatically
✅ All features work

---

## Troubleshooting

### If still crashing:

1. **Check iOS version** (requires iOS 13.0+)
2. **Update Flutter**:
   ```bash
   flutter upgrade
   ```
3. **Clear all caches**:
   ```bash
   flutter clean
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

### Check device logs:
In Xcode: Window > Devices and Simulators > Select your device > View Device Logs

---

## ✅ SOLUTION: Always use --profile or --release on physical iPhone!

**DO NOT** use `flutter run` (debug mode) on physical iPhone with this Flutter version.

---

🎉 **The app is working! Just use profile or release mode!**
