# 🔍 DEBUG: Self-Healing Location State

## 🚨 Cambios Implementados (Corrección)

### ✅ 1. Lifecycle Observer con Logs
**Archivo**: `map_page.dart`

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  debugPrint('🔄 AppLifecycleState changed: $state');
  
  if (state == AppLifecycleState.resumed) {
    debugPrint('✅ App RESUMED - Checking permissions...');
    context.read<MapBloc>().add(const CheckPermissionsEvent());
  }
}
```

**Qué hace**: Detecta cuando la app vuelve a primer plano (resumed) y automáticamente verifica permisos.

---

### ✅ 2. CheckPermissions con Geolocator Directo
**Archivo**: `map_bloc.dart`

```dart
Future<void> _onCheckPermissions(...) async {
  // USAR GEOLOCATOR DIRECTAMENTE
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  final permission = await Geolocator.checkPermission();
  
  final hasPermission = permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
  
  // Actualizar estado
  emit(currentState.copyWith(
    hasLocationPermission: hasPermission,
    isLocationEnabled: serviceEnabled && hasPermission,
  ));
  
  // Auto-centrar si todo OK
  if (hasPermission && serviceEnabled) {
    add(const CenterOnUserLocationEvent());
  }
}
```

**Cambio clave**: Usa `Geolocator` directamente en lugar de `LocationPermissionService` para verificaciones más precisas.

---

### ✅ 3. RequestPermission Refactorizado
**Archivo**: `map_bloc.dart`

```dart
Future<void> _onRequestPermission(...) async {
  // 1. Verificar GPS
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    emit(MapError('GPS deshabilitado...'));
    return;
  }
  
  // 2. Verificar permisos actuales
  LocationPermission permission = await Geolocator.checkPermission();
  
  // 3. Solicitar si están denegados
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  
  // 4. Manejar deniedForever
  if (permission == LocationPermission.deniedForever) {
    emit(MapError('Permisos denegados permanentemente...'));
    return;
  }
  
  // 5. Si granted, re-inicializar
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    add(const InitializeMapEvent());
  }
}
```

**Beneficio**: Maneja todos los casos de permisos (denied, deniedForever, granted) correctamente.

---

### ✅ 4. Auto-Check en Inicialización
**Archivo**: `map_bloc.dart`

```dart
Future<void> _onInitializeMap(...) async {
  // ... renderizar mapa ...
  
  // STEP 5: Verificar permisos automáticamente
  add(const CheckPermissionsEvent());
  
  // STEP 6: Cargar vehículos
  add(const LoadVehicleLocationsEvent());
}
```

**Beneficio**: Si los permisos ya fueron otorgados previamente, se detectan automáticamente al iniciar.

---

### ✅ 5. Banner de Permisos Persistente
**Archivo**: `map_page.dart`

```dart
if (state is MapLoaded) {
  return Stack(
    children: [
      CustomMapView(...),
      
      // Banner de permisos
      if (!state.isLocationEnabled)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 4,
            color: errorContainer,
            child: Padding(
              child: Row(
                children: [
                  Icon(Icons.location_off),
                  Text('Ubicación deshabilitada'),
                  ElevatedButton(
                    onPressed: () => RequestLocationPermissionEvent(),
                    child: Text('Habilitar'),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
```

**Beneficio**: El usuario siempre ve un banner visible para habilitar permisos, sin necesidad de buscar opciones.

---

### ✅ 6. Logs de Debug Completos

Todos los métodos ahora tienen logs detallados:
- `🔄 AppLifecycleState changed`
- `✅ App RESUMED`
- `🔍 CheckPermissions event received`
- `📡 Location services enabled`
- `🔐 Current permission`
- `🎯 Location enabled`
- `🎉 Permisos OK! Centrando cámara...`
- `📍 RequestLocationPermission event received`
- `📝 Permission after request`

---

## 🧪 Cómo Probar (Testing Manual)

### Escenario 1: Permisos Ya Otorgados
1. Instalar app
2. Otorgar permisos cuando se soliciten
3. Cerrar app (kill process)
4. **Reabrir app**

**Resultado Esperado**:
- ✅ Mapa renderiza instantáneamente
- ✅ Logs muestran: `🔍 CheckPermissions event received`
- ✅ Logs muestran: `✅ Has permission: true`
- ✅ Logs muestran: `🎉 Permisos OK! Centrando cámara...`
- ✅ Punto azul visible
- ✅ Cámara centrada en ubicación del usuario

---

### Escenario 2: Self-Healing desde Configuración
1. Abrir app SIN permisos (mapa en gris)
2. Ver banner rojo: "Ubicación deshabilitada"
3. **Salir de la app** (no cerrar, solo ir a home)
4. Ir a **Configuración > Aplicaciones > Aschu > Permisos**
5. Otorgar permiso de ubicación manualmente
6. **Volver a la app** (tap en recientes o ícono)

**Resultado Esperado**:
- ✅ Logs muestran: `🔄 AppLifecycleState changed: AppLifecycleState.resumed`
- ✅ Logs muestran: `✅ App RESUMED - Checking permissions...`
- ✅ Logs muestran: `🔍 CheckPermissions event received`
- ✅ Logs muestran: `✅ Has permission: true`
- ✅ Banner rojo desaparece
- ✅ Punto azul aparece
- ✅ Cámara se centra automáticamente

---

### Escenario 3: GPS Deshabilitado
1. Abrir app con permisos otorgados
2. Desactivar GPS en ajustes rápidos
3. Volver a la app

**Resultado Esperado**:
- ✅ Banner rojo: "Activa el GPS en configuración"
- ✅ Punto azul oculto
- ✅ Logs muestran: `📡 Location services enabled: false`

4. Activar GPS
5. Volver a la app

**Resultado Esperado**:
- ✅ Logs muestran: `📡 Location services enabled: true`
- ✅ Banner desaparece
- ✅ Punto azul aparece
- ✅ Auto-centra

---

### Escenario 4: Botón "Habilitar" en Banner
1. Abrir app sin permisos
2. Tap en botón "Habilitar" del banner rojo

**Resultado Esperado**:
- ✅ Logs muestran: `🔘 Permission button pressed`
- ✅ Logs muestran: `📍 RequestLocationPermission event received`
- ✅ Dialog de sistema aparece solicitando permisos
- ✅ Al aceptar: logs muestran `✅ Permission granted!`
- ✅ Mapa se re-inicializa
- ✅ Punto azul aparece
- ✅ Auto-centra

---

### Escenario 5: FloatingActionButton "Mi Ubicación"
1. Abrir app con permisos
2. Mover cámara manualmente lejos de la ubicación
3. Tap en FAB "Mi ubicación" (ícono azul)

**Resultado Esperado**:
- ✅ Logs muestran: `📍 CenterOnUserLocation event received`
- ✅ Logs muestran: `📡 Getting current location...`
- ✅ Logs muestran: `✅ Ubicación obtenida: lat, lng`
- ✅ Logs muestran: `🎥 Animando cámara...`
- ✅ Logs muestran: `🎉 Cámara centrada en ubicación del usuario!`
- ✅ Cámara se anima suavemente a la ubicación

---

## 🐛 Debugging con LogCat

### Comando para ver logs:
```bash
# Filtrar logs de Flutter
adb logcat | grep -E "flutter|Geolocator"

# O ver todo el log de la app
flutter logs
```

### Logs a buscar:
```
🔄 AppLifecycleState changed: AppLifecycleState.resumed
✅ App RESUMED - Checking permissions...
🔍 CheckPermissions event received
📡 Location services enabled: true
🔐 Permission status: LocationPermission.whileInUse
✅ Has permission: true
🎯 Location enabled: true
🔄 State updated - isLocationEnabled: true
🎉 Permisos OK! Centrando cámara...
📍 CenterOnUserLocation event received
🗺️ Map created - isLocationEnabled: true
✅ Auto-centering on user location
📡 Getting current location...
✅ Ubicación obtenida: -14.1197, -72.2458
🎥 Animando cámara...
🎉 Cámara centrada en ubicación del usuario!
```

---

## ❌ Posibles Problemas y Soluciones

### Problema 1: Banner no desaparece
**Causa**: Estado no se actualiza
**Debug**:
```bash
# Ver logs de CheckPermissions
adb logcat | grep "CheckPermissions"
```
**Solución**: Verificar que `isLocationEnabled` se actualiza a `true` en el estado.

---

### Problema 2: Punto azul no aparece
**Causa**: `myLocationEnabled` no está vinculado correctamente
**Debug**:
```dart
// En CustomMapView, agregar log:
debugPrint('🔵 myLocationEnabled: ${widget.myLocationEnabled}');
```
**Solución**: Verificar que `state.isLocationEnabled` es `true` y se pasa correctamente.

---

### Problema 3: didChangeAppLifecycleState no se llama
**Causa**: Observer no registrado
**Debug**: Verificar que `WidgetsBinding.instance.addObserver(this)` está en `initState`.
**Solución**: Asegurar que `_MapPageContentState` es `StatefulWidget`.

---

### Problema 4: Permisos granted pero no centra
**Causa**: MapController es null
**Debug**:
```bash
# Ver logs de CenterOnUserLocation
adb logcat | grep "CenterOnUserLocation"
```
**Solución**: Verificar que `setMapController` se llama en `onMapCreated`.

---

## 🎯 Checklist Final

- [ ] App detecta permisos al iniciar (si ya fueron otorgados)
- [ ] App detecta permisos al volver de configuración (resume)
- [ ] Banner rojo aparece cuando no hay permisos
- [ ] Banner desaparece cuando se otorgan permisos
- [ ] Punto azul aparece con permisos
- [ ] Punto azul desaparece sin permisos
- [ ] Auto-centra cuando se otorgan permisos
- [ ] FAB "Mi ubicación" funciona
- [ ] Botón "Habilitar" en banner funciona
- [ ] Mapa nunca crashea (renderiza en gris sin permisos)
- [ ] Logs de debug visibles en consola

---

## 🚀 Próximos Pasos

Si todo funciona:
1. **Remover logs de debug** para producción
2. **Optimizar frecuencia de checks** (evitar spam de CheckPermissions)
3. **Agregar analytics** para medir tasa de otorgamiento de permisos
4. **Implementar onboarding** explicando por qué se necesitan permisos

Si algo falla:
1. **Revisar logs** con los comandos de debug
2. **Verificar AndroidManifest.xml** tiene permisos declarados
3. **Probar en dispositivo físico** (emulador tiene bugs con GPS)
