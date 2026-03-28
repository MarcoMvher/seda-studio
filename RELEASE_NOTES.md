# SEDA Studio v1.0.0

## Features

### Core Functionality
- ✅ Order address display (t_address field from LegacyOrder)
- ✅ Auto-detect user role from Django backend (is_staff flag)
- ✅ Removed manual login tabs - backend determines role automatically
- ✅ Branch-based filtering for delegates with DelegateProfile
- ✅ View-only mode for branch users (is_staff=True)
- ✅ Full customer and visit management
- ✅ Measurement recording with photo attachments
- ✅ Order history tracking (completed visits)

### User Roles
1. **Delegate (مندوب)** - Regular users
   - Full access to create/edit visits and measurements
   - Can add photos and complete visits
   - Filtered by their assigned branch

2. **Branch User (فرع)** - Staff members
   - View-only access to all visits
   - Cannot create or edit visits
   - See all visits from their branch

### Platforms
- 📱 **iOS** - Runner.app (39 MB)
- 🤖 **Android** - 3 APKs (armeabi-v7a, arm64-v8a, x86_64)
- 🌐 **Web** - https://marcomvher.github.io/seda-studio/

## Installation

### iOS
1. Download `Runner.app.zip`
2. Unzip and install on iOS device
3. Or sideload using Xcode

### Android
Download the appropriate APK for your device architecture:
- `app-arm64-v8a-release.apk` - Modern devices (recommended)
- `app-armeabi-v7a-release.apk` - Older 32-bit devices
- `app-x86_64-release.apk` - Emulators

### Configuration
- **API Base URL:** https://seda.maverikode.com/api
- **Web URL:** https://marcomvher.github.io/seda-studio/

## Technical Details

### Backend Changes
- CustomerViewSet: Filter customers/orders by branch
- VisitViewSet: Multiple visits per order support
- MeasurementViewSet: Auto-update visit status
- DelegateProfile: Branch assignment for users

### Frontend Changes
- LoginScreen: Auto-detect role, removed tabs
- CustomerDetailsScreen: Display order addresses
- VisitsListScreen: New view-only screen for branch users
- Order model: Added t_address field

## GitHub Repository
https://github.com/MarcoMvher/seda-studio

## Web Version
https://marcomvher.github.io/seda-studio/
