# Qawaqawa Rural Logistics

Enterprise-grade Flutter application for rural logistics management with real-time vehicle tracking.

## 🏗️ Architecture

This project follows **Clean Architecture** principles, organized by features:

```
lib/
├── core/
│   ├── constants/
│   │   └── map_styles.dart          # Dark GTA-style map theme
│   ├── di/
│   │   ├── injection_container.dart  # GetIt setup
│   │   ├── injection_container.config.dart
│   │   └── register_module.dart      # Injectable modules
│   ├── error/
│   │   ├── exceptions.dart           # Exception definitions
│   │   └── failures.dart             # Failure classes with Dartz
│   └── theme/
│       └── app_theme.dart            # Single source of truth for theming
│
└── features/
    └── map/
        ├── data/
        │   ├── datasources/
        │   │   ├── map_remote_datasource.dart
        │   │   └── map_remote_datasource_impl.dart
        │   ├── models/
        │   │   └── vehicle_location_model.dart
        │   └── repositories/
        │       └── map_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── vehicle_location.dart
        │   ├── repositories/
        │   │   └── map_repository.dart
        │   └── usecases/
        │       ├── get_vehicle_locations.dart
        │       └── watch_vehicle_location.dart
        └── presentation/
            ├── bloc/
            │   ├── map_bloc.dart
            │   ├── map_event.dart
            │   └── map_state.dart
            ├── pages/
            │   └── map_page.dart
            └── widgets/
                └── custom_map_view.dart
```

## 🎨 Design System

### Color Palette
- **Primary**: Electric Amber `#FFB300`
- **Scaffold Background**: `#0C0C0C`
- **Surface**: `#1A1A1A`
- **Error**: `#FF5252`

### Typography
- **Font Family**: Inter (via Google Fonts)

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Update `lib/main.dart` with your Supabase credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Generate Code

Run code generation for Injectable and other builders:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Google Maps (Secure Method) 🔐

#### Android (Recommended - Zero Hardcoding)

**IMPORTANT**: We use `secrets.properties` for security - NO hardcoding!

1. **Create secrets file** in project root:
   ```bash
   cp secrets.properties.example secrets.properties
   ```

2. **Add your API key** to `secrets.properties`:
   ```properties
   MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_API_KEY
   ```

3. **Get your API key** from [Google Cloud Console](https://console.cloud.google.com/):
   - Enable "Maps SDK for Android"
   - Create API key
   - Restrict to your app's package name (`com.example.aschu`) and SHA-1

4. **Build and run**:
   ```bash
   flutter clean
   flutter run
   ```

The API key is automatically injected into AndroidManifest.xml during build via Secrets Gradle Plugin.

📖 **Detailed Guide**: See [API_KEY_SETUP.md](API_KEY_SETUP.md)

#### iOS
Add your API key in `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Database Schema (Supabase)

Create the following table in Supabase:

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

-- Create index for faster queries
CREATE INDEX idx_vehicle_locations_vehicle_id ON vehicle_locations(vehicle_id);
CREATE INDEX idx_vehicle_locations_timestamp ON vehicle_locations(timestamp DESC);
```

## 🏃 Run the App

```bash
flutter run
```

## 📦 Key Dependencies

- **State Management**: `flutter_bloc` ^8.1.6
- **Dependency Injection**: `get_it` ^7.7.0, `injectable` ^2.4.4
- **Functional Programming**: `dartz` ^0.10.1
- **Backend**: `supabase_flutter` ^2.6.0
- **Maps**: `google_maps_flutter` ^2.9.0
- **Location**: `geolocator` ^12.0.0
- **Typography**: `google_fonts` ^6.2.1

## 🛠️ Code Quality

- ✅ 100% Null-safety
- ✅ Const constructors where possible
- ✅ Separation of concerns (UI/Business Logic)
- ✅ Equatable for value comparison
- ✅ Functional error handling with Either<Failure, Success>

## 📍 Initial Map Position

**Challhuahuacho, Peru**
- Latitude: -14.1197
- Longitude: -72.2458
- Zoom: 14.0

## 🌙 Map Style

Dark GTA Minimalist theme with Electric Amber highlights for highways.

## 📝 License

Private Project

