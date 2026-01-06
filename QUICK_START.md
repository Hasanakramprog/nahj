# 🚀 QUICK START - Physical iPhone

## The Problem
App crashes in **debug mode** on physical iPhone (Flutter engine bug).

## The Solution  
✅ **Use profile or release mode!**

---

## Run Now (Choose One)

### Option 1: Profile Mode (Recommended)
```bash
cd /Users/macbook/Desktop/nahj/nahj_app
flutter run --profile
```

### Option 2: Release Mode
```bash
cd /Users/macbook/Desktop/nahj/nahj_app
flutter run --release
```

### Option 3: Via Xcode
```bash
open ios/Runner.xcworkspace
```
Then: Product > Scheme > Select "Profile" or "Release" > Run ▶️

---

## ⛔ DO NOT USE
```bash
flutter run  # This crashes on physical iPhone!
```

---

## Development Workflow

1. **Develop**: iOS Simulator (debug works fine)
2. **Test**: Physical iPhone (use --profile)
3. **Release**: Physical iPhone (use --release)

---

## App Features ✨

- ✅ Auto dark/light mode (follows system)
- ✅ Sermon navigation with next/previous
- ✅ Swipe gestures
- ✅ Bookmarks
- ✅ Search
- ✅ Multiple Arabic fonts
- ✅ Adjustable font size

---

**Questions? Check `RUN_ON_PHYSICAL_IPHONE.md` for full details.**
