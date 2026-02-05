# 🔐 Quick Reference - Secure API Key Setup

## ✅ Files Created

| File | Location | Purpose | Git Status |
|------|----------|---------|------------|
| `secrets.properties` | Project root | **YOUR ACTUAL API KEY** | ❌ NOT COMMITTED |
| `secrets.properties.example` | Project root | Template for team | ✅ Committed |
| `.env` | Project root | Optional: Flutter runtime | ❌ NOT COMMITTED |
| `.env.example` | Project root | Template for Flutter | ✅ Committed |

## 🚀 Quick Start Commands

```bash
# 1. Copy template
cp secrets.properties.example secrets.properties

# 2. Edit and add your key
# Replace tu_llave_aqui with your actual Google Maps API key

# 3. Build and run
flutter clean
flutter run
```

## 📝 secrets.properties Format

```properties
MAPS_API_KEY=AIzaSyB_YOUR_ACTUAL_KEY_HERE_XXXXXXXXXXXXXX
```

## 🔍 Verify Installation

```bash
# Clean build
cd android
./gradlew clean

# Build debug APK
./gradlew app:assembleDebug

# Check if key was injected (should show your key)
cat ../build/app/intermediates/merged_manifests/debug/*/AndroidManifest.xml | grep API_KEY
```

## 🛡️ Security Checklist

- ✅ `secrets.properties` in `.gitignore`
- ✅ No hardcoded keys in `AndroidManifest.xml`
- ✅ API key injected via Secrets Gradle Plugin at build time
- ✅ Keys restricted in Google Cloud Console
- ✅ Package name: `com.example.aschu`
- ✅ SHA-1 fingerprint registered

## 📱 Get SHA-1 Fingerprint

### Debug Key
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Windows (PowerShell)
```powershell
keytool -list -v -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 🌍 Google Cloud Console Setup

1. Go to: https://console.cloud.google.com/
2. Select/Create project
3. Enable API: **Maps SDK for Android**
4. Create Credentials → API Key
5. Restrict Key:
   - **Application restrictions**: Android apps
   - **Package name**: `com.example.aschu`
   - **SHA-1**: (from command above)
   - **API restrictions**: Maps SDK for Android

## 🚨 Common Issues

### "Map shows 'For development purposes only'"
**Fix**: Add SHA-1 fingerprint to API key restrictions

### "Build fails - secrets.properties not found"
**Fix**: Ensure file exists in project root (not android/)

### "Map doesn't load"
**Fix 1**: Check API key is correct in `secrets.properties`
**Fix 2**: Verify key restrictions in Google Cloud Console
**Fix 3**: Clean and rebuild: `flutter clean && flutter run`

## 📦 Project Structure

```
aschu/
├── secrets.properties          ← YOUR KEY HERE (not in git)
├── secrets.properties.example  ← Template
├── .env                        ← Optional: Flutter config
├── android/
│   ├── settings.gradle.kts    ← Plugin declared
│   └── app/
│       ├── build.gradle.kts   ← Plugin configured
│       └── src/main/
│           └── AndroidManifest.xml  ← Uses ${MAPS_API_KEY}
```

## 🔄 Team Workflow

### New Developer Setup
1. Clone repository
2. `cp secrets.properties.example secrets.properties`
3. Get API key from Google Cloud Console
4. Add key to `secrets.properties`
5. `flutter run`

### CI/CD Pipeline
```yaml
# GitHub Actions example
- name: Create secrets file
  run: echo "MAPS_API_KEY=${{ secrets.MAPS_API_KEY }}" > secrets.properties
```

## 📚 Documentation Files

- **[API_KEY_SETUP.md](API_KEY_SETUP.md)** - Detailed setup guide
- **[README.md](README.md)** - Project overview
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Code structure

## ✨ What's Configured

✅ Secrets Gradle Plugin 2.0.1  
✅ Zero hardcoding in code  
✅ Auto-injection at build time  
✅ BuildConfig access: `BuildConfig.MAPS_API_KEY`  
✅ Manifest injection: `${MAPS_API_KEY}`  
✅ Git ignore configured  
✅ Permissions added (Location, Internet)  
✅ Enterprise-grade security  

---

**Ready to test!** Just add your API key and run `flutter run` 🚀
