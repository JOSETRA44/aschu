# 🔐 Secure API Key Management - Setup Guide

## Overview

This project uses the **Secrets Gradle Plugin** to securely manage Google Maps API keys without hardcoding them in the codebase. This is an enterprise-grade security practice that prevents accidental exposure of sensitive credentials.

## 🏗️ Architecture

```
Project Root/
├── .env                          # Flutter Dart configuration (for runtime)
├── .env.example                  # Template for documentation
├── secrets.properties            # Android native config (NEVER COMMIT!)
├── secrets.properties.example    # Template for Android
├── .gitignore                    # Ensures secrets files never tracked
└── android/
    ├── settings.gradle.kts       # Declares secrets plugin
    ├── app/
    │   ├── build.gradle.kts      # Configures secrets plugin
    │   └── src/main/
    │       └── AndroidManifest.xml   # Uses ${MAPS_API_KEY} placeholder
```

## 🚀 Quick Start

### 1. Get Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Maps SDK for Android**
4. Navigate to **APIs & Services > Credentials**
5. Create an API Key and restrict it to:
   - **Application restrictions**: Android apps
   - **API restrictions**: Maps SDK for Android
   - Add your app's SHA-1 fingerprint

### 2. Configure Environment Variables

#### For Android (Gradle)

Copy the example file and add your key:

```bash
cp secrets.properties.example secrets.properties
```

Edit `secrets.properties` and replace `tu_llave_aqui` with your actual API key:

```properties
MAPS_API_KEY=AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

#### For Flutter/Dart (Optional - Runtime Config)

Also configure `.env` for Flutter runtime access:

```bash
cp .env.example .env
```

Edit `.env`:

```env
MAPS_API_KEY=AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 3. Verify Git Ignore

Ensure secrets files are in `.gitignore` (already configured):

```gitignore
# Secrets - NEVER COMMIT
secrets.properties
.env
.env.local
```

### 4. Run the App

```bash
flutter clean
flutter pub get
flutter run
```

## 🔒 Security Features Implemented

### ✅ Zero Hardcoding
- No API keys in `AndroidManifest.xml`
- No keys in version control
- Keys loaded at build time only

### ✅ Gradle Secrets Plugin
- **Plugin Version**: 2.0.1 (latest stable)
- **Configuration**: Reads from `.env` in project root
- **Fallback**: Uses `.env.example` if main file missing

### ✅ Manifest Injection
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

### ✅ BuildConfig Access
API key is also available in Kotlin/Java code:
```kotlin
val apiKey = BuildConfig.MAPS_API_KEY
```

## 📱 Permissions Added

The following permissions were added to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

## 🛠️ How It Works

### Build Process Flow

1. **Developer creates `.env`** with `MAPS_API_KEY=YOUR_KEY`
2. **Gradle reads `.env`** during build via Secrets Plugin
3. **Plugin injects key** into `AndroidManifest.xml` at `${MAPS_API_KEY}`
4. **BuildConfig generated** with key as constant
5. **App runs** with key loaded at runtime

### Plugin Configuration (`app/build.gradle.kts`)

```kotlin
secrets {
    // Path to secrets.properties file (root directory)
    propertiesFileName = "secrets.properties"
    
    // Default properties file for fallback (template)
    defaultPropertiesFileName = "secrets.properties.example"
    
    // Ignore missing properties during development
    ignoreList.add("keyToIgnore")
    ignoreList.add("sdk.*")
}
```

## 🧪 Testing

### Verify Key Injection

Build the app and check generated files:

```bash
cd android
./gradlew app:assembleDebug --info
```

Check generated `AndroidManifest.xml`:
```bash
cat app/build/intermediates/merged_manifests/debug/AndroidManifest.xml | grep API_KEY
```

### Test on Device

```bash
flutter run
```

Expected: Map loads at Challhuahuacho coordinates (-14.1197, -72.2458)

## 🚨 Troubleshooting

### Error: "API key not found"

**Solution**: Ensure `secrets.properties` exists in project root with correct format:
```properties
MAPS_API_KEY=YOUR_KEY_HERE
```

### Error: "API_KEY not set in properties"

**Solution**: Clean and rebuild:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Map shows "For development purposes only"

**Solution**: Your API key needs proper restrictions:
1. Go to Google Cloud Console
2. Edit your API key
3. Add your app's package name: `com.example.aschu`
4. Add SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

## 📊 Best Practices Implemented

✅ **Separation of Concerns**: Config separate from code  
✅ **DRY Principle**: Single source of truth for keys  
✅ **Security First**: No secrets in version control  
✅ **Scalability**: Easy to add more environment variables  
✅ **Team Friendly**: `.env.example` documents required keys  
✅ **CI/CD Ready**: Build server can inject keys via environment  

## 🔄 Adding More Secrets

To add additional API keys or secrets:

1. Add to `secrets.properties`:
   ```properties
   MAPS_API_KEY=your_maps_key
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   ```

2. Add to `secrets.properties.example`:
   ```properties
   MAPS_API_KEY=YOUR_MAPS_KEY
   SUPABASE_URL=YOUR_SUPABASE_URL
   SUPABASE_KEY=YOUR_SUPABASE_KEY
   ```

3. Access in build.gradle.kts:
   ```kotlin
   buildConfigField("String", "SUPABASE_URL", "\"${project.findProperty("SUPABASE_URL") ?: ""}\"")
   ```

4. Use in AndroidManifest.xml:
   ```xml
   <meta-data
       android:name="com.example.CUSTOM_KEY"
       android:value="${YOUR_CUSTOM_KEY}" />
   ```

## 🌐 Production Deployment

### For CI/CD Pipelines

Set environment variables in your CI/CD system:

**GitHub Actions**:
```yaml
- name: Create secrets.properties file
  run: |
    echo "MAPS_API_KEY=${{ secrets.MAPS_API_KEY }}" > secrets.properties
```

**GitLab CI**:
```yaml
before_script:
  - echo "MAPS_API_KEY=$MAPS_API_KEY" > secrets.properties
```

### For Play Store Release

1. Create production API key with proper restrictions
2. Store in secure vault (e.g., Google Secret Manager)
3. Inject during build process
4. Never commit production keys

## 📝 File Checklist

- ✅ `secrets.properties` - Created with your API key (NOT in git)
- ✅ `secrets.properties.example` - Template committed to repo
- ✅ `.env` - Optional: For Flutter/Dart runtime access
- ✅ `.env.example` - Template for Flutter config
- ✅ `.gitignore` - Updated to exclude secrets files
- ✅ `settings.gradle.kts` - Plugin declared
- ✅ `app/build.gradle.kts` - Plugin configured
- ✅ `AndroidManifest.xml` - Placeholder injection added
- ✅ Permissions added for location and maps

## 🎯 Ready for Production

This setup is:
- ✅ **Secure**: No hardcoded secrets
- ✅ **Scalable**: Easy to manage multiple environments
- ✅ **Professional**: Industry-standard approach
- ✅ **Maintainable**: Clear separation of config and code
- ✅ **Team-ready**: Documented and reproducible

## 📚 Additional Resources

- [Secrets Gradle Plugin Documentation](https://github.com/google/secrets-gradle-plugin)
- [Google Maps Platform API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Android App Security](https://developer.android.com/topic/security/best-practices)

---

**Last Updated**: February 2026  
**Plugin Version**: secrets-gradle-plugin 2.0.1  
**Android Gradle Plugin**: 8.9.1  
**Minimum SDK**: As configured in Flutter
