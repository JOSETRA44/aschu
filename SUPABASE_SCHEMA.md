# 🗄️ Supabase Database Schema - Qawaqawa Rural Logistics

## CRITICAL: Ejecutar este schema ANTES de usar la app

Este schema define las tablas requeridas para el sistema de tracking en tiempo real de conductores y vehículos.

---

## 📋 Tabla: `driver_locations`

### SQL Schema

```sql
-- ==================== DRIVER LOCATIONS TABLE ====================
-- Almacena ubicaciones de conductores en tiempo real
-- Optimizado para zonas rurales con conexión intermitente

CREATE TABLE IF NOT EXISTS public.driver_locations (
    -- Primary Key
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Driver Information
    driver_id TEXT NOT NULL,
    driver_name TEXT,
    phone_number TEXT,
    
    -- Location Data
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION, -- Precisión en metros
    altitude DOUBLE PRECISION,
    heading DOUBLE PRECISION, -- Dirección 0-360 grados
    speed DOUBLE PRECISION, -- Velocidad en m/s
    
    -- Status
    is_online BOOLEAN DEFAULT true,
    current_vehicle_id TEXT, -- Vehículo asignado actualmente
    
    -- Timestamp
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_driver_locations_driver_id 
    ON public.driver_locations(driver_id);

CREATE INDEX IF NOT EXISTS idx_driver_locations_is_online 
    ON public.driver_locations(is_online);

CREATE INDEX IF NOT EXISTS idx_driver_locations_timestamp 
    ON public.driver_locations(timestamp DESC);

-- Índice compuesto para query de conductores activos
CREATE INDEX IF NOT EXISTS idx_driver_locations_active 
    ON public.driver_locations(is_online, timestamp DESC) 
    WHERE is_online = true;

-- Índice para geolocalización (opcional, requiere PostGIS)
-- CREATE INDEX IF NOT EXISTS idx_driver_locations_geo 
--     ON public.driver_locations USING GIST (
--         ll_to_earth(latitude, longitude)
--     );

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_driver_locations_updated_at ON public.driver_locations;

CREATE TRIGGER update_driver_locations_updated_at
    BEFORE UPDATE ON public.driver_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Política de Row Level Security (RLS)
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden leer ubicaciones de conductores online
CREATE POLICY "Anyone can read online driver locations"
    ON public.driver_locations
    FOR SELECT
    USING (is_online = true);

-- Política: Solo conductores autenticados pueden actualizar su ubicación
CREATE POLICY "Drivers can update their own location"
    ON public.driver_locations
    FOR INSERT
    WITH CHECK (auth.uid()::text = driver_id);

CREATE POLICY "Drivers can update their own location data"
    ON public.driver_locations
    FOR UPDATE
    USING (auth.uid()::text = driver_id)
    WITH CHECK (auth.uid()::text = driver_id);

-- Cleanup: Borrar ubicaciones antiguas (más de 7 días)
-- Ejecutar con pg_cron o manualmente
CREATE OR REPLACE FUNCTION cleanup_old_driver_locations()
RETURNS void AS $$
BEGIN
    DELETE FROM public.driver_locations
    WHERE timestamp < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON TABLE public.driver_locations IS 'Ubicaciones en tiempo real de conductores Qawaqawa';
COMMENT ON COLUMN public.driver_locations.accuracy IS 'Precisión GPS en metros';
COMMENT ON COLUMN public.driver_locations.heading IS 'Dirección de movimiento en grados (0-360)';
COMMENT ON COLUMN public.driver_locations.speed IS 'Velocidad en metros por segundo';
```

---

## 📋 Tabla: `vehicle_locations` (Ya existente - referencia)

### SQL Schema

```sql
-- ==================== VEHICLE LOCATIONS TABLE ====================
-- Almacena ubicaciones de vehículos en tiempo real

CREATE TABLE IF NOT EXISTS public.vehicle_locations (
    -- Primary Key
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Vehicle Information
    vehicle_id TEXT NOT NULL,
    driver_name TEXT, -- Conductor actual
    vehicle_type TEXT,
    license_plate TEXT,
    
    -- Location Data
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    altitude DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamp
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_vehicle_locations_vehicle_id 
    ON public.vehicle_locations(vehicle_id);

CREATE INDEX IF NOT EXISTS idx_vehicle_locations_is_active 
    ON public.vehicle_locations(is_active);

CREATE INDEX IF NOT EXISTS idx_vehicle_locations_timestamp 
    ON public.vehicle_locations(timestamp DESC);

-- Trigger updated_at
DROP TRIGGER IF EXISTS update_vehicle_locations_updated_at ON public.vehicle_locations;

CREATE TRIGGER update_vehicle_locations_updated_at
    BEFORE UPDATE ON public.vehicle_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE public.vehicle_locations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active vehicle locations"
    ON public.vehicle_locations
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Authenticated users can insert vehicle locations"
    ON public.vehicle_locations
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update vehicle locations"
    ON public.vehicle_locations
    FOR UPDATE
    USING (auth.role() = 'authenticated');
```

---

## 🔄 Realtime Subscriptions Setup

### Habilitar Realtime en Supabase Dashboard

1. Ir a **Database > Replication**
2. Habilitar Realtime para las tablas:
   - `driver_locations`
   - `vehicle_locations`

3. O ejecutar SQL:

```sql
-- Habilitar Realtime para driver_locations
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_locations;

-- Habilitar Realtime para vehicle_locations
ALTER PUBLICATION supabase_realtime ADD TABLE public.vehicle_locations;
```

---

## 📊 Datos de Prueba (Opcional)

### Insertar conductores de prueba

```sql
-- Insertar 3 conductores en zona rural de Challhuahuacho
INSERT INTO public.driver_locations (driver_id, driver_name, phone_number, latitude, longitude, accuracy, heading, speed, is_online, current_vehicle_id) VALUES
    ('driver_001', 'Juan Pérez', '+51987654321', -14.1197, -72.2458, 5.0, 45.0, 10.5, true, 'vehicle_001'),
    ('driver_002', 'María García', '+51987654322', -14.1205, -72.2465, 8.0, 90.0, 12.0, true, 'vehicle_002'),
    ('driver_003', 'Carlos López', '+51987654323', -14.1180, -72.2440, 6.5, 180.0, 8.5, false, NULL);
```

### Insertar vehículos de prueba

```sql
INSERT INTO public.vehicle_locations (vehicle_id, driver_name, vehicle_type, license_plate, latitude, longitude, accuracy, heading, speed, is_active) VALUES
    ('vehicle_001', 'Juan Pérez', 'Camioneta 4x4', 'ABC-123', -14.1197, -72.2458, 5.0, 45.0, 10.5, true),
    ('vehicle_002', 'María García', 'Minivan', 'XYZ-789', -14.1205, -72.2465, 8.0, 90.0, 12.0, true),
    ('vehicle_003', 'Sin Conductor', 'Pickup', 'DEF-456', -14.1180, -72.2440, 10.0, 0.0, 0.0, false);
```

---

## 🔒 Security Best Practices

### 1. Autenticación de Conductores

```sql
-- Crear tabla de conductores autenticados
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    driver_id TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    license_number TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para drivers
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Drivers can read their own data"
    ON public.drivers
    FOR SELECT
    USING (auth.uid() = id);
```

### 2. Rate Limiting para Updates

```sql
-- Prevenir spam de updates (máximo 1 por segundo)
CREATE OR REPLACE FUNCTION check_update_rate_limit()
RETURNS TRIGGER AS $$
DECLARE
    last_update TIMESTAMPTZ;
BEGIN
    SELECT timestamp INTO last_update
    FROM public.driver_locations
    WHERE driver_id = NEW.driver_id
    ORDER BY timestamp DESC
    LIMIT 1;
    
    IF last_update IS NOT NULL AND 
       (NOW() - last_update) < INTERVAL '1 second' THEN
        RAISE EXCEPTION 'Rate limit exceeded: Updates must be at least 1 second apart';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS driver_location_rate_limit ON public.driver_locations;

CREATE TRIGGER driver_location_rate_limit
    BEFORE INSERT ON public.driver_locations
    FOR EACH ROW
    EXECUTE FUNCTION check_update_rate_limit();
```

---

## 📈 Performance Tuning

### Vacuum y Analyze Periódico

```sql
-- Ejecutar periódicamente para mantener performance
VACUUM ANALYZE public.driver_locations;
VACUUM ANALYZE public.vehicle_locations;
```

### Partitioning (Opcional para gran volumen)

```sql
-- Particionar por mes para mejorar performance con datos históricos
CREATE TABLE driver_locations_2026_02 PARTITION OF driver_locations
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
```

---

## 🧪 Testing Queries

### Query 1: Obtener conductores online

```sql
SELECT 
    driver_id,
    driver_name,
    latitude,
    longitude,
    accuracy,
    speed,
    timestamp
FROM public.driver_locations
WHERE is_online = true
ORDER BY timestamp DESC;
```

### Query 2: Rastrear conductor específico

```sql
SELECT 
    timestamp,
    latitude,
    longitude,
    heading,
    speed
FROM public.driver_locations
WHERE driver_id = 'driver_001'
ORDER BY timestamp DESC
LIMIT 10;
```

### Query 3: Conductores cerca de una ubicación

```sql
-- Requiere extensión earthdistance
CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;

SELECT 
    driver_id,
    driver_name,
    latitude,
    longitude,
    earth_distance(
        ll_to_earth(-14.1197, -72.2458),
        ll_to_earth(latitude, longitude)
    ) / 1000 AS distance_km
FROM public.driver_locations
WHERE is_online = true
HAVING earth_distance(
    ll_to_earth(-14.1197, -72.2458),
    ll_to_earth(latitude, longitude)
) < 5000 -- 5km radio
ORDER BY distance_km;
```

---

## 🚀 Deployment Checklist

- [ ] Ejecutar schema de `driver_locations`
- [ ] Ejecutar schema de `vehicle_locations` (si no existe)
- [ ] Habilitar Realtime en ambas tablas
- [ ] Configurar RLS policies
- [ ] Insertar datos de prueba
- [ ] Verificar índices creados
- [ ] Setup pg_cron para cleanup (opcional)
- [ ] Configurar monitoring y alertas
- [ ] Backup automático habilitado

---

**Última actualización:** 2026-02-04  
**Compatible con:** Supabase PostgreSQL 15+  
**Proyecto:** Qawaqawa Rural Logistics
