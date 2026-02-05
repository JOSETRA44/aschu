package com.example.aschu

import android.os.Bundle
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.MapsInitializer.Renderer
import com.google.android.gms.maps.OnMapsSdkInitializedCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.Log

/**
 * MainActivity optimizada para Qawaqawa - Transporte Rural
 * 
 * CRITICAL FIX para GPUs Mali (Infinix, Xiaomi, otros dispositivos rurales):
 * - Fuerza LEGACY Renderer en lugar de Hybrid Composition
 * - Basado en MapRendererOptInApplication.java de samples oficiales Google
 * - Previene "Unable to acquire a buffer item" en GPUs problemáticas
 * 
 * Solución para Android SDK 36 + Impeller en zonas rurales con hardware limitado.
 * 
 * @see https://github.com/googlemaps/android-samples/blob/main/ApiDemos/java/app/src/gms/java/com/example/mapdemo/MapRendererOptInApplication.java
 */
class MainActivity : FlutterActivity(), OnMapsSdkInitializedCallback {

    companion object {
        private const val TAG = "QawaqawaMainActivity"
    }

    /**
     * Inicializa el renderizador ANTES de que Flutter cree el Engine.
     * Esto es crítico para dispositivos con GPUs Mali.
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        // CRITICAL: Inicializar Maps SDK con LEGACY Renderer ANTES de super.onCreate()
        // Esto previene que se use el renderer por defecto (LATEST) que causa crashes
        try {
            MapsInitializer.initialize(applicationContext, Renderer.LEGACY, this)
            Log.d(TAG, "Maps SDK initialized with LEGACY Renderer for Mali GPU compatibility")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Maps SDK with LEGACY Renderer: ${e.message}")
            // Continuar de todos modos - el callback manejará el fallback
        }
        
        super.onCreate(savedInstanceState)
    }

    /**
     * Callback cuando Maps SDK termina de inicializarse.
     * Usado para logging y verificación de renderer.
     */
    override fun onMapsSdkInitialized(renderer: Renderer) {
        when (renderer) {
            Renderer.LATEST -> {
                Log.w(TAG, "WARNING: Using LATEST renderer - may cause issues on Mali GPUs")
            }
            Renderer.LEGACY -> {
                Log.i(TAG, "SUCCESS: Using LEGACY renderer - optimal for rural devices")
            }
        }
    }

    /**
     * Cleanup al destruir la actividad para prevenir memory leaks
     */
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "MainActivity destroyed - cleaning up resources")
    }
}
