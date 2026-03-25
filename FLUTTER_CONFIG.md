# Flutter App Configuration

**Flutter App Path:** `/home/marco-maher/Projects/Seda Studio/flutter`

---

## ✅ API Configuration Updated

### Production API Endpoint
**Base URL:** `http://62.169.26.136:8080`

**API Endpoints:**
- Authentication: `http://62.169.26.136:8080/api/auth/`
- Customers: `http://62.169.26.136:8080/api/customers/`
- Legacy Customers: `http://62.169.26.136:8080/api/legacy/customers/`
- Legacy Orders: `http://62.169.26.136:8080/api/legacy/orders/`
- Visits: `http://62.169.26.136:8080/api/visits/`
- Measurements: `http://62.169.26.136:8080/api/measurements/`
- Images: `http://62.169.26.136:8080/api/images/`

### Configuration File
**File:** `lib/config/app_config.dart`

```dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://62.169.26.136:8080', // Production VPS endpoint
  );

  static const String apiPath = '/api';
  static const String authPath = '/api/auth';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

---

## 🔐 Authentication

### API Credentials
- **Username:** `admin`
- **Password:** `Admin123!`

### Authentication Flow
1. POST `/api/auth/login/` with username/password
2. Receive JWT access token and refresh token
3. Include access token in Authorization header: `Bearer <token>`
4. Token auto-refresh on 401 responses

---

## 📱 Building & Running the App

### Development Mode (with local backend)
```bash
# Set environment variable for local development
export API_BASE_URL=http://localhost:8000

# Or for physical device on local network
export API_BASE_URL=http://192.168.1.124:8000

# Run the app
cd /home/marco-maher/Projects/Seda\ Studio/flutter
flutter run
```

### Production Mode (uses default VPS endpoint)
```bash
cd /home/marco-maher/Projects/Seda\ Studio/flutter
flutter run --release
```

### Android
```bash
# Build APK
flutter build apk --release

# Output: flutter/build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Build iOS app
flutter build ios --release

# Requires Xcode and proper provisioning
```

---

## 🧪 Testing the Connection

### Option 1: Use the test_api.py script
```bash
cd /home/marco-maher/Projects/Seda Studio/backend
python test_api.py
```

### Option 2: Manual curl test
```bash
# Test login
curl -X POST http://62.169.26.136:8080/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'

# Save the token, then test API
TOKEN="<your_access_token>"
curl http://62.169.26.136:8080/api/legacy/customers/ \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📋 Available API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/refresh/` - Refresh access token

### Customers
- `GET /api/customers/` - List all customers
- `POST /api/customers/` - Create new customer
- `GET /api/customers/{id}/` - Get customer details
- `PUT /api/customers/{id}/` - Update customer
- `DELETE /api/customers/{id}/` - Delete customer

### Legacy Data (SQL Server Sync)
- `GET /api/legacy/customers/` - List legacy customers
- `GET /api/legacy/orders/` - List legacy orders
- `GET /api/legacy/orders/{orderno}/` - Get order with items

### Visits
- `GET /api/visits/` - List all visits
- `POST /api/visits/` - Create new visit
- `GET /api/visits/{id}/` - Get visit details
- `PUT /api/visits/{id}/` - Update visit
- `DELETE /api/visits/{id}/` - Delete visit

### Measurements
- `GET /api/measurements/` - List measurements
- `POST /api/measurements/` - Create measurement
- `GET /api/measurements/{id}/` - Get measurement details
- `PUT /api/measurements/{id}/` - Update measurement

### Images
- `GET /api/images/` - List images
- `POST /api/images/` - Upload visit image
- `GET /api/images/{id}/` - Get image details
- `DELETE /api/images/{id}/` - Delete image

---

## 🔄 Data Sync Status

### Current Data
- **Legacy Customers:** 76
- **Legacy Orders:** 100+
- **Local Customers:** 76
- **Branches:** Not synced yet (use sync_branches.py)

### Sync Commands (on server)
```bash
# Sync orders from supplier مشغل ستارتى
docker exec -it seda_backend python /app/sync_supplier_orders.py

# Sync all branches
docker exec -it seda_backend python /app/sync_branches.py
```

---

## 🐛 Troubleshooting

### Connection Issues
1. **Verify backend is running:**
   ```bash
   curl http://62.169.26.136:8080/admin/
   ```

2. **Check API is accessible:**
   ```bash
   curl http://62.169.26.136:8080/api/auth/login/ \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"Admin123!"}'
   ```

3. **Test from Flutter app:**
   - Enable PrettyDioLogger (already enabled in api_service.dart)
   - Check console for API requests/responses

### Authentication Issues
1. **Verify credentials:** admin / Admin123!
2. **Check token storage:** Tokens stored in FlutterSecureStorage (mobile) or SharedPreferences (web)
3. **Clear old tokens:** Logout and login again

### Network Issues
1. **Timeout increased to 15 seconds** in AppConfig
2. **VPS firewall:** Port 8080 must be open
3. **ZeroTier VPN:** Verify connection between office server and VPS

---

## 📦 Building for Production

### Android APK
```bash
cd /home/marco-maher/Projects/Seda\ Studio/flutter

# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA
```bash
# Build release IPA
flutter build ios --release

# Requires Xcode for signing and distribution
```

### Web (if configured)
```bash
# Build for web
flutter build web

# Output: build/web/
```

---

## 🔧 Environment Variables

### Override API URL at Runtime

**Android:**
```bash
# Before running
export API_BASE_URL=http://192.168.1.124:8000
flutter run
```

**iOS (Xcode):**
1. Open Xcode
2. Select Runner target
3. Build Settings → Environment Variables
4. Add: `API_BASE_URL = http://192.168.1.124:8000`

**Web:**
Set environment variable before running:
```bash
export API_BASE_URL=http://localhost:8000
flutter run -d chrome
```

---

## 📱 App Features

### Current Features
- ✅ Customer management
- ✅ Visit tracking
- ✅ Measurement recording
- ✅ Image upload
- ✅ Legacy data viewing (SQL Server sync)
- ✅ JWT authentication with auto-refresh
- ✅ Secure token storage

### Planned Features
- Order management
- Real-time sync notifications
- Offline mode support
- Barcode scanning
- PDF report generation

---

## 🚀 Deployment Checklist

- [x] API endpoint configured
- [x] Production URL set
- [x] Authentication tested
- [x] API endpoints verified
- [ ] APK built and tested
- [ ] iOS build configured
- [ ] App signed for distribution
- [ ] Error logging implemented
- [ ] Crash reporting configured
- [ ] Analytics integrated

---

**Last Updated:** 2026-03-12
**Status:** ✅ Configuration updated, ready for testing
