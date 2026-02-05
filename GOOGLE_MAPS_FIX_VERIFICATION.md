# 🗺️ Google Maps Rendering Fix - Guía de Verificación

## ✅ Implementación Completada

### Solución Aplicada: Hybrid Composition + Android 14/15 Compliance

**Problema Original:**
- Google Maps mostraba pantalla gris/blanca en Android SDK 36 con Impeller activo
- Errores en logcat: "Unable to acquire a buffer item", "lockHardwareCanvas"
- Incompatibilidad entre Impeller y Platform Views estándar

**Solución Implementada:**
- ✅ **MainActivity.kt**: Forzar Hybrid Composition en `configureFlutterEngine()`
- ✅ **AndroidManifest.xml**: Permisos Android 14/15 + meta-data para Hybrid Composition
- ✅ **LocationPermissionService**: Manejo granular de permisos (precise/approximate/background)
- ✅ **MapBloc**: Refactorizado con camera events, permission handling, lifecycle management
- ✅ **CustomMapView**: Optimizado con AutomaticKeepAliveClientMixin, dispose seguro
- ✅ **MapPage**: BlocConsumer con diálogos de permisos y manejo de errores

---

## 📋 Checklist de Verificación

### 1. Pre-Build Verification

```powershell
# Verificar que las dependencias están instaladas
flutter pub get

# Regenerar código de inyección de dependencias
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar que no hay errores de compilación
flutter analyze
```

**Resultado esperado:** 
- ✅ No errors found
- ✅ Archivos `.config.dart` y `.module.dart` regenerados

---

### 2. Build Verification

```powershell
# Limpiar build anterior
flutter clean

# Build release para Android
flutter build apk --release

# O build debug para testing
flutter build apk --debug
```

**Resultado esperado:**
- ✅ BUILD SUCCESSFUL (similar a "BUILD SUCCESSFUL in 3m 36s")
- ✅ APK generado en `build/app/outputs/flutter-apk/`

---

### 3. Runtime Verification (Emulador/Device con Android SDK 36)

#### A. Instalación y Launch

```powershell
# Listar devices disponibles
flutter devices

# Ejecutar en device/emulator
flutter run --release
```

#### B. Checklist Visual

**Pantalla de Mapa:**
- [ ] El mapa se muestra correctamente (NO pantalla gris/blanca)
- [ ] El estilo oscuro (darkMapStyle) se aplica correctamente
- [ ] Los marcadores de vehículos aparecen en las coordenadas correctas
- [ ] El botón "Mi ubicación" funciona (si permisos concedidos)
- [ ] Zoom y pan funcionan sin lag
- [ ] No hay frame skips visibles durante gestos

**Flujo de Permisos:**
1. [ ] Al abrir la app, aparece diálogo "Permiso de Ubicación"
2. [ ] Al tocar "Permitir", se solicita permiso del sistema
3. [ ] Al otorgar permiso, el mapa carga inmediatamente
4. [ ] Si se niega permiso, aparece error claro con botón "Intentar de nuevo"
5. [ ] Botón de ubicación en AppBar funciona para re-verificar permisos

#### C. Logcat Verification

```powershell
# Filtrar logs de Flutter
flutter logs | Select-String -Pattern "GoogleMap|lockHardwareCanvas|acquire.*buffer|Impeller|PlatformView"
```

**Resultado esperado:**
- ✅ **NO** debe aparecer: "Unable to acquire a buffer item"
- ✅ **NO** debe aparecer: "lockHardwareCanvas: Handle was not bound"
- ✅ **SÍ** debe aparecer: "Using Hybrid Composition for maps" (o similar)
- ✅ **SÍ** debe aparecer: "GoogleMap created successfully"

---

### 4. Performance Verification

#### A. Flutter DevTools

```powershell
# Abrir DevTools en navegador
flutter pub global run devtools

# Mientras la app corre:
flutter run --profile
```

**Métricas a verificar:**
- **Frame Rendering Time**: < 16ms (60 FPS)
- **GPU Thread**: < 16ms
- **Memory Usage**: Estable (no incremento constante = memory leak)
- **Jank Count**: 0 frames dropped durante 30 segundos de pan/zoom

#### B. Manual Testing

**Test 1: Pan & Zoom Stress Test**
1. Hacer zoom in/out rápidamente 10 veces
2. Pan en todas direcciones durante 20 segundos
3. **Resultado esperado:** Fluidez constante, sin stuttering

**Test 2: Memory Leak Test**
1. Navegar fuera de MapPage y volver 5 veces
2. **Resultado esperado:** No incremento de memoria en cada ciclo

**Test 3: Camera Position Cache**
1. Hacer pan a una ubicación específica
2. Navegar fuera y volver a MapPage
3. **Resultado esperado:** Mapa debe mantener la última posición de cámara

---

### 5. Permission Flow Verification (Android 14/15)

#### Test Cases:

**Caso A: Primera vez (sin permisos)**
1. Desinstalar app: `adb uninstall com.example.aschu`
2. Reinstalar y abrir
3. [ ] Debe aparecer diálogo de la app primero
4. [ ] Al tocar "Permitir", sistema solicita permiso
5. [ ] Otorgar "Precise location"
6. [ ] Mapa carga inmediatamente

**Caso B: Permisos denegados**
1. Ir a Settings > Apps > Aschu > Permissions
2. Denegar ubicación
3. Abrir app
4. [ ] Debe mostrar pantalla "Permisos de ubicación requeridos"
5. [ ] Tocar botón "Otorgar permisos"
6. [ ] Sistema abre configuración de permisos

**Caso C: Permisos aproximados (Android 12+)**
1. Otorgar solo "Approximate location"
2. [ ] App debe funcionar pero con menor precisión
3. [ ] No debe crashear

---

## 🔧 Troubleshooting

### Problema: Aún aparece pantalla gris

**Solución 1: Verificar Hybrid Composition**
```kotlin
// MainActivity.kt debe tener:
override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    flutterEngine.platformViewsController.registry.registerViewFactory(
        "com.google.maps.flutter",
        GoogleMapsPlugin.GoogleMapsPlatformViewFactory()
    )
}
```

**Solución 2: Verificar AndroidManifest.xml**
```xml
<!-- Debe contener: -->
<application android:hardwareAccelerated="true" android:largeHeap="true">
    <meta-data
        android:name="io.flutter.embedded_views_preview"
        android:value="true" />
</application>
```

**Solución 3: Limpiar cache de Gradle**
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

---

### Problema: Errores de permisos en Android 14+

**Verificar AndroidManifest.xml tiene:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**Verificar LocationPermissionService se usa en MapBloc:**
```dart
final permissionResult = await _locationPermissionService.requestFullLocationAccess();
```

---

### Problema: Memory leaks o crashes al navegar

**Verificar CustomMapView dispose:**
```dart
@override
void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
}
```

**Verificar MapBloc close:**
```dart
@override
Future<void> close() {
    _vehicleSubscription?.cancel();
    _disposeMapController();
    return super.close();
}
```

---

## 📊 Métricas de Éxito

| Métrica | Target | Cómo Verificar |
|---------|--------|----------------|
| Frame Rate | 60 FPS | Flutter DevTools > Performance |
| Frame Render Time | < 16ms | DevTools > Timeline |
| Memory Usage | Estable | DevTools > Memory (no incremento constante) |
| Cold Start Time | < 3s | Cronómetro desde tap hasta mapa visible |
| Permission Grant Time | < 2s | Desde "Permitir" hasta mapa cargado |
| Map Tiles Load | < 1s | Tiles visibles tras pan |

---

## ✨ Arquitectura Final

```
MapPage (BlocConsumer)
  ├── MapBloc (state management)
  │   ├── LocationPermissionService (Android 14/15 compliance)
  │   ├── GetVehicleLocations (use case)
  │   └── WatchVehicleLocation (use case)
  │
  ├── CustomMapView (StatefulWidget + AutomaticKeepAliveClientMixin)
  │   ├── GoogleMapController (lifecycle managed)
  │   ├── Camera events (onCameraMove, onCameraIdle)
  │   └── Dark map style (GTA-inspired)
  │
  └── Permission Dialogs (Material 3)

MainActivity.kt (Hybrid Composition)
  └── GoogleMapsPlugin.GoogleMapsPlatformViewFactory

AndroidManifest.xml
  ├── Hybrid Composition meta-data
  ├── Hardware acceleration
  ├── Large heap
  └── Comprehensive location permissions
```

---

## 🚀 Next Steps (Opcionales)

1. **Optimización de Network**
   - Implementar caching de tiles con `google_maps_flutter` offline mode
   - Configurar tile prefetching para rutas conocidas

2. **Geofencing**
   - Usar `geolocator` para detectar entrada/salida de zonas
   - Notificaciones cuando vehículos entran a áreas críticas

3. **Clustering de Marcadores**
   - Implementar `google_maps_cluster_manager` para muchos vehículos
   - Mejorar performance con 100+ vehículos simultáneos

4. **Background Location Tracking**
   - Usar `workmanager` para tracking periódico
   - Implementar `ACCESS_BACKGROUND_LOCATION` con justificación clara

---

## 📞 Soporte

**Si el mapa aún no renderiza después de seguir esta guía:**

1. Capturar logcat completo:
   ```powershell
   flutter logs > flutter_logs.txt
   adb logcat > android_logs.txt
   ```

2. Verificar versiones:
   ```powershell
   flutter --version
   flutter doctor -v
   ```

3. Información crítica a revisar:
   - ¿Qué versión de Android SDK (35/36)?
   - ¿Emulador o device físico?
   - ¿Aparece algún warning sobre Impeller en logs?
   - ¿El API key de Google Maps es válido?

---

**Documentación de Referencia:**
- [Flutter Impeller](https://docs.flutter.dev/perf/impeller)
- [Hybrid Composition](https://docs.flutter.dev/platform-integration/android/platform-views)
- [Android 14 Location Permissions](https://developer.android.com/about/versions/14/changes/platform-behavior#precise-location)
- [google_maps_flutter Package](https://pub.dev/packages/google_maps_flutter)

---

**Última actualización:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
