# 🚀 Quick Start Guide - Qawaqawa Rural Logistics

## ✅ Completed Setup

The following has been implemented and configured:

### ✨ Architecture
- ✅ Clean Architecture with 3 layers (Domain, Data, Presentation)
- ✅ Feature-based organization
- ✅ Dependency Injection with GetIt + Injectable
- ✅ State Management with flutter_bloc
- ✅ Functional error handling with Dartz

### 🎨 Theming
- ✅ AppTheme class with Dark Mode as default
- ✅ Electric Amber (#FFB300) primary color
- ✅ Dark background (#0C0C0C, #1A1A1A)
- ✅ Google Fonts (Inter) integration

### 🗺️ Map Feature
- ✅ VehicleLocation entity
- ✅ MapBloc with InitializeMap & UpdateLocation events
- ✅ CustomMapView widget (Challhuahuacho coordinates)
- ✅ Dark GTA Minimalist map style
- ✅ Complete Clean Architecture implementation

### 📦 Dependencies
- ✅ All dependencies configured in pubspec.yaml
- ✅ Code generation completed
- ✅ All files formatted

## 🔧 Required Configuration

Before running the app, you need to configure:

### 1️⃣ Supabase Credentials

Open `lib/main.dart` and replace placeholders:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your Supabase project URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
);
```

**Get credentials from:**
1. Go to https://supabase.com
2. Create a new project (if needed)
3. Go to Settings → API
4. Copy "URL" and "anon public" key

### 2️⃣ Supabase Database Table

Run this SQL in Supabase SQL Editor:

```sql
CREATE TABLE vehicle_locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  heading DOUBLE PRECISION,
  speed DOUBLE PRECISION,
  driver_name TEXT,
  vehicle_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicle_locations_vehicle_id ON vehicle_locations(vehicle_id);
CREATE INDEX idx_vehicle_locations_timestamp ON vehicle_locations(timestamp DESC);
```

### 3️⃣ Google Maps API Key

#### For Android:

1. Get API key from: https://console.cloud.google.com/google/maps-apis/
2. Open `android/app/src/main/AndroidManifest.xml`
3. Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### For iOS:

1. Open `ios/Runner/AppDelegate.swift`
2. Add at the top:

```swift
import GoogleMaps
```

3. Add inside `application` function:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 4️⃣ Enable Google Maps APIs

In Google Cloud Console, enable these APIs:
- Maps SDK for Android
- Maps SDK for iOS

## 🏃 Running the App

### Option 1: Run on Connected Device

```bash
flutter run
```

### Option 2: Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Option 3: Run with Hot Reload

```bash
flutter run --hot
```

## 🧪 Testing

Run unit tests:

```bash
flutter test
```

## 🔄 Regenerate Code (if needed)

If you modify Injectable annotations:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🗺️ Initial Map View

The app will open showing:
- **Location**: Challhuahuacho, Peru
- **Coordinates**: -14.1197, -72.2458
- **Zoom Level**: 14.0
- **Map Style**: Dark GTA Minimalist

## 🎯 Next Development Steps

1. **Add Sample Data**: Insert test vehicle locations in Supabase
2. **Location Permissions**: Configure location permissions for real-time tracking
3. **Real-time Updates**: Connect to Supabase realtime for live vehicle tracking
4. **Authentication**: Add Supabase Auth for user management
5. **Additional Features**: Routes, delivery tracking, notifications

## 📁 Project Structure

```
lib/
├── core/               # Shared infrastructure
│   ├── constants/      # Map styles, colors
│   ├── di/            # Dependency injection
│   ├── error/         # Error handling
│   └── theme/         # App theming
└── features/
    └── map/           # Map feature (Clean Architecture)
        ├── data/      # Data layer
        ├── domain/    # Business logic
        └── presentation/ # UI layer
```

## 🐛 Troubleshooting

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Map Not Showing
- Verify Google Maps API key is correct
- Check that billing is enabled in Google Cloud
- Ensure Maps SDK is enabled

### Supabase Connection Issues
- Verify URL and anon key are correct
- Check internet connection
- Verify Supabase project is running

## 📚 Documentation

- [README.md](README.md) - Main documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture guide
- This file - Quick start guide

## 🎉 You're Ready!

Once you've configured Supabase and Google Maps, run:

```bash
flutter run
```

The app will launch showing the dark-themed map centered on Challhuahuacho! 🗺️✨
