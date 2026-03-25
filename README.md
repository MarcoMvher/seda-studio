# SEDA Studio - Flutter App

Flutter mobile application for field delegates to capture customer visits and measurements for curtain/fabric cutting.

## Tech Stack

- **Flutter 3.x** - Mobile framework
- **Provider** - State management
- **Dio** - HTTP client
- **flutter_secure_storage** - Secure token storage
- **image_picker** - Camera/gallery access

## Features

- JWT-based authentication
- Customer search and listing
- Visit management (create, update status)
- Measurement recording (space name, dimensions, quantity, notes)
- Photo capture and upload
- Offline-ready architecture (token refresh, error handling)

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.x
- Android Studio / VS Code with Flutter extensions
- Android device/emulator

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API URL

Edit [lib/config/app_config.dart](lib/config/app_config.dart):

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000', // Android emulator
);
```

**For different environments:**

- **Android Emulator**: `http://10.0.2.2:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000` (find your IP with `ipconfig` or `ifconfig`)
- **Production**: `https://your-api-domain.com`

**Or pass via build argument:**

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
```

### 4. Run the App

```bash
flutter run
```

## App Structure

```
lib/
├── config/
│   └── app_config.dart          # API configuration
├── models/
│   ├── customer.dart
│   ├── measurement.dart
│   ├── visit.dart
│   ├── visit_image.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   ├── customer_provider.dart   # Customer state
│   └── visit_provider.dart      # Visit & measurement state
├── screens/
│   ├── login_screen.dart
│   ├── customer_list_screen.dart
│   ├── customer_details_screen.dart
│   └── visit_details_screen.dart
├── services/
│   ├── api_service.dart         # Dio + JWT handling
│   ├── auth_service.dart
│   ├── customer_service.dart
│   └── visit_service.dart
└── main.dart
```

## Screens

### 1. Login Screen
- Username/password authentication
- JWT token storage
- Auto-login on app restart

### 2. Customer List Screen
- Search customers by name/phone
- Pull-to-refresh
- Tap to view customer details

### 3. Customer Details Screen
- View customer information
- List of past visits
- "Start Visit" button to create new visit

### 4. Visit Details Screen
- View visit information
- Add measurements (space name, width, height, quantity, notes)
- Delete measurements
- Upload photos from camera
- Update visit status (Pending, In Progress, Completed, Cancelled)

## API Integration

The app communicates with the Django REST API:

- **Authentication**: JWT tokens (access + refresh)
- **Auto-refresh**: Token refresh on 401 errors
- **Image Upload**: Multipart form data
- **Error Handling**: User-friendly error messages

## State Management

Uses Provider pattern:

- `AuthProvider`: Login state, token management
- `CustomerProvider`: Customer list, search
- `VisitProvider`: Visit list, measurements, images

## Build for Production

### Android

```bash
# Generate APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

Output location:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

### Set Production API URL

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

## Permissions

The app requires the following permissions (configured in AndroidManifest.xml):

- `INTERNET` - API communication
- `CAMERA` - Photo capture
- `READ_EXTERNAL_STORAGE` - Gallery access (Android < 13)
- `WRITE_EXTERNAL_STORAGE` - Image storage (Android < 13)

## Troubleshooting

### Connection Refused

- Ensure backend server is running
- Check API_BASE_URL in app_config.dart
- For physical device, use your computer's local IP (not localhost)

### Token Issues

- Clear app data to reset authentication
- Check backend token lifetime settings
- Ensure device time is correct (JWT validation)

### Image Upload Fails

- Check media permissions
- Verify backend MEDIA_URL configuration
- Check network connectivity

## Development Notes

- No offline mode in MVP (future enhancement)
- Image upload placeholder in visit_details_screen.dart (line ~422)
- Use `flutter_secure_storage` for all sensitive data
- All API calls use Dio interceptors for auth headers
