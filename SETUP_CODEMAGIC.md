# Setup Guide: Codemagic for iOS Build

This guide will help you set up your Flutter app with Codemagic to build the iOS version.

---

## Step 1: Create GitHub Repository

### Option A: Using GitHub Website (Recommended)
1. Go to https://github.com/new
2. Repository name: `seda-studio` (or your preferred name)
3. Description: `Seda Studio - Field measurement & visit management app`
4. **Choose:** Private or Public (Private for your app)
5. **DO NOT** initialize with README, .gitignore, or license (we already have them)
6. Click "Create repository"

### Option B: Using GitHub CLI
```bash
# Install GitHub CLI if not installed
# sudo apt install gh  # On Ubuntu/Debian

# Login to GitHub
gh auth login

# Create repository
gh repo create seda-studio --private --source=. --remote=origin --push
```

---

## Step 2: Connect Local Git to GitHub

After creating the repository on GitHub, you'll see commands like this:

```bash
cd "/home/marco-maher/Projects/Seda Studio/flutter"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/seda-studio.git

# Push to GitHub (use -u to set upstream)
git push -u origin main
```

**Replace `YOUR_USERNAME` with your actual GitHub username.**

---

## Step 3: Verify on GitHub

1. Go to your GitHub repository
2. You should see all your Flutter code
3. Verify the structure looks correct

---

## Step 4: Create Apple Developer Account

### Required for App Store & TestFlight

1. Go to https://developer.apple.com/programs/enroll/
2. Click "Enroll"
3. Sign in with your Apple ID
4. Pay $99/year fee
5. Wait for enrollment to complete (usually 24-48 hours)

### After Enrollment:
1. Go to https://appstoreconnect.apple.com
2. Create your app:
   - Apps → My Apps → +
   - Bundle ID: `com.yourcompany.sedaStudio`
   - Name: `Seda Studio`
   - Platform: iOS

---

## Step 5: Create Codemagic Account

1. Go to https://codemagic.io
2. Click "Get started" or "Sign up"
3. Sign up with **GitHub** (recommended)
4. Authorize Codemagic to access your repositories

---

## Step 6: Connect Your App to Codemagic

1. In Codemagic dashboard, click **"Add new app"**
2. Select **GitHub**
3. Choose your repository: `seda-studio`
4. Click **"Select"**

---

## Step 7: Configure Codemagic Build

### Basic Configuration:
1. **Project type:** Flutter
2. **Flutter project path:** `./` (root of repo)
3. **Build configuration:** Use codemagic.yaml file

### Workflow Configuration:
The `codemagic.yaml` file is already in your project with:
- Flutter SDK setup
- iOS build configuration
- Code signing setup (automatic)
- Build artifacts

---

## Step 8: Set Up Code Signing

### One-Time Setup:

1. In Codemagic, go to your app settings
2. Click **"iOS code signing"**
3. Choose **"Automatic code signing"**
4. Click **"Connect Apple account"**
5. Sign in with your Apple Developer account
6. Grant permissions

### Codemagic Will Automatically:
- Generate distribution certificate
- Create provisioning profiles
- Handle all signing for you

---

## Step 9: Start Your First Build!

### Build Your iOS App:

1. In Codemagic, click **"Start new build"**
2. Select branch: `main`
3. Workflow: `iOS Build` (from codemagic.yaml)
4. Click **"Start new build"**
5. Wait for build (~10-15 minutes)

### What Happens:
- ✅ Downloads Flutter SDK
- ✅ Installs dependencies
- ✅ Builds iOS app
- ✅ Code signs automatically
- ✅ Creates .ipa file

---

## Step 10: Download Your App

1. When build completes, click on it
2. Go to **"Artifacts"** tab
3. Download **`Runner.app.zip`** or **`.ipa`** file
4. This is your iOS app!

---

## Step 11: Test on Your iPhone

### Option A: TestFlight (Recommended - Free)
1. In Codemagic, enable **"Publish to TestFlight"**
2. Next build will automatically upload to TestFlight
3. Go to App Store Connect
4. Add testers (yourself + others)
5. Testers get email with TestFlight link
6. Install TestFlight app
7. Download and test your app!

### Option B: Direct Install (Ad-hoc)
Requires:
- Physical iPhone
- USB cable
- Apple Configurator (Mac) or similar tool
- Provisioning profile with device UDID

---

## Publish to App Store

### Before Publishing:
1. **App Icon:** Create 1024x1024px PNG
   - Place in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Name: `Icon-App-1024x1024.png`

2. **Screenshots:** Required sizes:
   - 6.7" display: 1290x2796px
   - 6.5" display: 1242x2688px
   - 5.5" display: 1242x2208px

3. **App Information:**
   - Name: Seda Studio
   - Description (Arabic & English)
   - Keywords
   - Category: Business
   - Privacy Policy URL

### Publishing Steps:
1. Complete all info in App Store Connect
2. In Codemagic, enable **"Submit to App Store"**
3. Build your app
4. Codemagic automatically submits for review
5. Wait 1-3 days for Apple review
6. Your app is live! 🎉

---

## Quick Reference Commands

### Git Commands:
```bash
# Check status
git status

# See changes
git diff

# Commit changes
git add .
git commit -m "Your message"

# Push to GitHub
git push

# Pull latest changes
git pull
```

### Flutter Commands:
```bash
# Get dependencies
flutter pub get

# Run on connected device (Android)
flutter run

# Build Android APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

---

## Troubleshooting

### Issue: "Permission denied" when pushing
```bash
# Use SSH instead of HTTPS
git remote set-url origin git@github.com:YOUR_USERNAME/seda-studio.git
git push -u origin main
```

### Issue: Codemagic can't access repository
- Go to Codemagic → Settings → Integrations
- Reconnect GitHub
- Grant repository access

### Issue: Code signing fails
- Verify Apple Developer account is active
- Check Bundle ID matches in App Store Connect
- Ensure automatic code signing is enabled in Codemagic

### Issue: Build fails
- Check build logs in Codemagic
- Verify `codemagic.yaml` is correct
- Ensure all Flutter dependencies are compatible

---

## File Locations

### Important Files:
```
flutter/
├── codemagic.yaml              # Codemagic configuration
├── ios/
│   ├── Runner/Info.plist       # App permissions
│   ├── Runner.xcodeproj/       # Xcode project
│   └── Podfile                 # iOS dependencies
├── android/
│   └── app/build.gradle        # Android config
├── lib/                        # Your Dart code
└── pubspec.yaml                # Flutter dependencies
```

### Bundle Identifier:
Current: `com.yourcompany.sedaStudio`

Change to your company name in:
- `ios/Runner.xcodeproj/project.pbxproj`
- App Store Connect

---

## Next Steps Checklist

- [x] Initialize Git repository
- [x] Create initial commit
- [ ] Create GitHub repository
- [ ] Push code to GitHub
- [ ] Create Apple Developer account
- [ ] Create Codemagic account
- [ ] Connect repository to Codemagic
- [ ] Configure code signing
- [ ] Build first iOS version
- [ ] Test on TestFlight
- [ ] Create app icon (1024x1024)
- [ ] Prepare screenshots
- [ ] Write app description
- [ ] Submit to App Store

---

## Cost Summary

| Item | Cost | Frequency |
|------|------|-----------|
| Apple Developer Program | $99 | Per year |
| Codemagic | Free | Open source repos |
| Codemagic | $12-99/month | Private repos |
| TestFlight | Free | - |
| App Store | Free | With Developer account |

---

## Support Links

- **Codemagic Docs:** https://docs.codemagic.io/
- **Flutter iOS Build:** https://docs.flutter.dev/platform-integration/ios
- **App Store Connect:** https://appstoreconnect.apple.com
- **Apple Developer:** https://developer.apple.com

---

## Current Status

✅ Git repository initialized
✅ Initial commit created
✅ Branch renamed to `main`
✅ Ready to push to GitHub

**Next:** Create GitHub repository and push your code!

```bash
# Replace YOUR_USERNAME with your GitHub username
cd "/home/marco-maher/Projects/Seda Studio/flutter"
git remote add origin https://github.com/YOUR_USERNAME/seda-studio.git
git push -u origin main
```

After that, you're ready to connect to Codemagic! 🚀
