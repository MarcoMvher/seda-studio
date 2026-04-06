# iOS Build Guide for Seda Studio

## Quick Summary
Since you're on Linux, you have these options to build for iOS:

### ✅ Recommended: Codemagic (Easiest)
1. Go to https://codemagic.io
2. Create free account
3. Connect your GitHub repository
4. Configure iOS build
5. They'll guide you through Apple Developer setup

### Alternative: GitHub Actions (Free)
1. Push your code to GitHub
2. I've created `.github/workflows/ios.yml` for you
3. Enable GitHub Actions in your repo
4. Add your Apple Developer credentials as secrets

---

## What You Need

### 1. Apple Developer Account
- **Required for**: App Store, TestFlight, code signing
- **Cost**: $99/year
- **Sign up**: https://developer.apple.com/programs/enroll/

### 2. Bundle Identifier
Your app's unique identifier (already configured):
- `com.yourcompany.sedaStudio`
- Change "yourcompany" to your actual company name

### 3. App Icons
You need a 1024x1024px PNG icon
- Place in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Name it: `Icon-App-1024x1024.png`

---

## Step-by-Step: Codemagic Build

### Step 1: Create Apple Developer Account
```
1. Go to developer.apple.com
2. Enroll in Apple Developer Program
3. Pay $99/year fee
4. Verify your email
```

### Step 2: Create App ID in App Store Connect
```
1. Go to App Store Connect
2. Apps -> My Apps -> +
3. Create new app
4. Bundle ID: com.yourcompany.sedaStudio
5. Platform: iOS
6. Name: Seda Studio
```

### Step 3: Set up Codemagic
```
1. Go to codemagic.io
2. Sign up/login with GitHub
3. Click "Add new app"
4. Select your repository
5. Configure:
   - Flutter project path: flutter/
   - Build: iOS
   - Workflow: Use codemagic.yaml file
```

### Step 4: Configure Code Signing (One-time)
```
In Codemagic dashboard:
1. Go to your app settings
2. "iOS code signing"
3. "Automatic code signing"
4. Connect your Apple Developer account
5. Codemagic will create:
   - Distribution certificate
   - Provisioning profiles
```

### Step 5: Build!
```
1. In Codemagic, click "Start new build"
2. Select branch: main
4. Wait for build (~10-15 minutes)
5. Download .ipa file
```

---

## Testing Your iOS App

### Option 1: TestFlight (Recommended)
```
1. Build completes on Codemagic
2. Automatically publish to TestFlight
3. Invite testers via email
4. Testers install TestFlight app
5. They download your app for testing
```

### Option 2: Direct Install (Ad-hoc)
```
Requires:
- Physical iOS device
- Provisioning profile with device UDID
- IPA file from Codemagic
- Apple Configurator or similar tool
```

---

## Publishing to App Store

### Prerequisites
- ✅ Apple Developer Account
- ✅ App created in App Store Connect
- ✅ Privacy Policy URL
- ✅ App screenshots (required sizes)
- ✅ App description
- ✅ App icons

### Steps
```
1. Build your app with Codemagic
2. In Codemagic, enable "Submit to App Store"
3. Or manually upload IPA to App Store Connect
4. Complete app information:
   - Description
   - Keywords
   - Screenshots
   - Age rating
   - Category
5. Submit for Review
6. Wait 1-3 days for approval
```

---

## Common Issues

### Issue: "No suitable signing certificates found"
**Solution**: Use Codemagic's automatic code signing

### Issue: "Bundle identifier already exists"
**Solution**: Change to unique identifier in project.pbxproj

### Issue: "Provisioning profile doesn't match"
**Solution**: Let Codemagic regenerate provisioning profiles

### Issue: "Build fails on Linux"
**Solution**: You MUST use cloud build service (Codemagic/GitHub Actions)

---

## File Locations

### Important iOS Files:
```
ios/
├── Runner/
│   ├── Info.plist          # App permissions & configuration
│   ├── AppDelegate.swift   # App entry point
│   └── Assets.xcassets/    # App icons & images
├── Podfile                 # iOS dependencies
├── Runner.xcodeproj/       # Xcode project
└── Runner.xcworkspace/     # Xcode workspace (use this)
```

### Configuration Files:
```
✅ ios/Runner/Info.plist    - App permissions (camera, photos)
✅ ios/Podfile              - iOS dependencies
✅ pubspec.yaml             - Flutter dependencies
✅ codemagic.yaml           - Codemagic build configuration
✅ .github/workflows/ios.yml - GitHub Actions (alternative)
```

---

## Next Steps

### Immediate (Today):
1. ✅ iOS folder structure created
2. 📝 Decide: Codemagic or GitHub Actions?
3. 💰 Get Apple Developer account ($99/year)
4. 🎨 Design 1024x1024 app icon

### This Week:
1. Connect your repository to build service
2. Configure code signing
3. Build first version
4. Test on TestFlight

### Before Publishing:
1. Write privacy policy
2. Prepare app screenshots
3. Write app description
4. Create support email/website

---

## Costs

| Item | Cost |
|------|------|
| Apple Developer Program | $99/year |
| Codemagic (paid plans) | $12-$99/month |
| Codemagic (open source) | Free |
| GitHub Actions | Free (public repos) |
| TestFlight | Free |
| App Store | Free (with Developer account) |

---

## Current Status

✅ iOS project structure created
✅ Info.plist configured with camera/photo permissions
✅ Podfile configured for iOS 12.0+
✅ Launch screen created
✅ Codemagic configuration ready
✅ GitHub Actions workflow ready

🟡 Still needed:
- Apple Developer Account
- App icon (1024x1024)
- Code signing setup
- First build

---

## Need Help?

### Codemagic Docs:
https://docs.codemagic.io/

### Flutter iOS Docs:
https://docs.flutter.dev/platform-integration/ios

### App Store Connect:
https://appstoreconnect.apple.com

---

## Commands (For macOS Only)

Since you're on Linux, these commands won't work locally.
Use Codemagic or GitHub Actions instead.

```bash
# These are for macOS only:
flutter build ios --release
open ios/Runner.xcworkspace  # Opens Xcode
flutter run                 # Run on connected device
```

---

**Your iOS app is ready to build! 🎉**

Choose Codemagic (recommended) or GitHub Actions, get an Apple Developer account, and you can build your first iOS version today.
