# Mercado Libre Mobile Testing - Ruby Appium

### Author

Erick Hernandez Velazco [github](https://github.com/ErickHdzV)
Correo: erick.hv@codebyerick.com

Este proyecto contiene pruebas automatizadas para la aplicación móvil de Mercado Lib### Errores**: Los selectores pueden cambiar con actualizaciones de la app 3. **Performance**: Se recomienda usar un emulador con buenas especificaciones para mejor rendimiento 4. **Red\*\*: Asegurar conexión estable a internet para que la app funcione correctamente

## 📋 Requisitos Previos

### Sistema Operativo

- **Windows** (configurado para Windows PowerShell)

### Software Requerido

#### 1. Ruby

- **Versión requerida**: Ruby 3.4.6 o superior
- Descargar desde: https://rubyinstaller.org/
- Verificar instalación: `ruby --version`

#### 2. Android SDK y ADB

- **Android SDK** instalado (puede ser a través de Android Studio)
- **ADB** disponible en PATH
- Verificar: `adb --version`

#### 3. Appium Server

- **Node.js** (versión 14 o superior)
- **Appium** instalado globalmente

```bash
npm install -g appium
npm install -g @appium/doctor
```

#### 4. Drivers de Appium

```bash
appium driver install uiautomator2
```

#### 5. Emulador Android o Dispositivo Físico

- **Emulador Android** configurado y funcionando
- O **dispositivo Android físico** con depuración USB habilitada

## 📱 Configuración del Dispositivo/Emulador

### Configuración del Emulador

1. Crear un emulador Android con:

- **Android Studio** > AVD Manager > Create Virtual Device
- **API Level**: 28 o superior
- **Target**: Google APIs
- **ABI**: x86_64 (recomendado para performance)

2. Iniciar el emulador:

```bash
emulator -avd <nombre_del_emulador>
```

3. Verificar que el emulador esté conectado:

```bash
adb devices
```

### Aplicación Mercado Libre

- **IMPORTANTE**: La aplicación de Mercado Libre debe estar instalada en el emulador/dispositivo
- Descargar desde Google Play Store en el emulador
- Package name: `com.mercadolibre`

## 🛠️ Configuración del Proyecto

### 1. Clonar/Obtener el Proyecto

```bash
cd d:\A_Mios\5-testing\mercado-libre-ruby
```

### 2. Instalar Dependencias Ruby

```bash
bundle install
```

### 3. Verificar Configuración Appium

```bash
appium-doctor --android
```

## 🚀 Ejecución de Pruebas

### 1. Iniciar Appium Server

En una terminal separada:

```bash
appium --use-plugins=inspector --allow-cors
```

El servidor se iniciará en: `http://127.0.0.1:4723`

### 2. Verificar que el Emulador/Dispositivo esté Conectado

```bash
adb devices
```

### 3. Ejecutar las Pruebas

```bash
ruby mercado_libre_spec.rb
```

## 📊 Funcionalidad de las Pruebas

### Escenario de Prueba Principal

1. **Abrir aplicación** Mercado Libre
2. **Buscar** "playstation 5"
3. **Aplicar filtros**:
   - Condición: Nuevo
   - Ordenar por: Mayor precio
4. **Extraer información** de los primeros 5 productos mostrados
5. **Generar reportes** con screenshots

### Estructura de Datos Extraídos

Para cada producto se obtiene:

- Número de posición (1-5)
- Nombre del producto
- Precio

## 📈 Visualización de Reportes

### Abrir Reporte HTML

1. Navega a la carpeta `reports/`
2. Busca el archivo más reciente: `test_report_YYYYMMDD_HHMMSS.html`
3. Haz doble clic para abrir en tu navegador predeterminado
4. El reporte incluye screenshots, métricas y detalles completos

### Ejemplo de Reporte

Para generar un reporte de ejemplo y ver el formato:

```bash
ruby report_generator.rb sample
```

### Ver Historial de Reportes

```bash
ruby report_generator.rb list
```

## 🎯 Métricas de los Reportes

Los reportes proporcionan las siguientes métricas:

- **Tiempo total de ejecución**
- **Número de pasos ejecutados**
- **Pasos exitosos vs fallidos**
- **Cantidad de screenshots capturados**
- **Productos encontrados y extraídos**
- **Errores detallados con timestamps**

## 🔧 Personalización de Reportes

Para personalizar los reportes, puedes modificar:

- `test_reporter.rb` - Estructura y contenido de reportes
- CSS en la plantilla HTML para cambiar el diseño
- Agregar nuevas métricas o secciones según necesidadesutilizando Ruby y Appium. Las pruebas verifican la funcionalidad de búsqueda, filtrado y ordenamiento de productos.

## 📁 Estructura del Proyecto

```
mercado-libre-ruby/
├── mercado_libre_spec.rb   # Archivo principal de pruebas
├── test_reporter.rb        # Sistema de generación de reportes
├── report_generator.rb     # Utilidad para gestión de reportes
├── Gemfile                 # Dependencias Ruby
├── Gemfile.lock           # Versiones específicas de dependencias
├── README.md              # Este archivo
└── reports/
    ├── screenshots/       # Capturas de pantalla generadas
    ├── test_report_YYYYMMDD_HHMMSS.json  # Reporte en formato JSON
    ├── test_report_YYYYMMDD_HHMMSS.html  # Reporte visual HTML
    └── test_report_YYYYMMDD_HHMMSS.txt   # Reporte en texto plano
```

## 📊 Sistema de Reportes

### Reportes Automáticos

Las pruebas generan automáticamente 3 tipos de reportes:

#### 1. **Reporte HTML** (Recomendado para visualización)

- Interfaz visual completa con gráficos
- Screenshots integrados
- Resumen ejecutivo
- Detalles paso a paso
- **Ubicación**: `reports/test_report_YYYYMMDD_HHMMSS.html`

#### 2. **Reporte JSON** (Para procesamiento automático)

- Datos estructurados para análisis
- Integración con otras herramientas
- **Ubicación**: `reports/test_report_YYYYMMDD_HHMMSS.json`

#### 3. **Reporte TXT** (Para lectura rápida)

- Formato texto plano
- Resumen conciso de resultados
- **Ubicación**: `reports/test_report_YYYYMMDD_HHMMSS.txt`

### Gestión de Reportes

#### Listar reportes existentes:

```bash
ruby report_generator.rb list
```

#### Generar reporte de ejemplo:

```bash
ruby report_generator.rb sample
```

#### Ver ayuda del generador:

```bash
ruby report_generator.rb help
```

### Contenido de los Reportes

Los reportes incluyen:

- ✅ **Resumen ejecutivo** con métricas de éxito/fallo
- ⏱️ **Duración total** de la prueba
- 📝 **Log detallado** de cada paso ejecutado
- 📸 **Screenshots** de cada etapa del proceso
- 🎮 **Lista de productos** encontrados con precios
- ❌ **Errores** detallados si ocurren fallos
- 📊 **Estadísticas** de ejecución

## 🔧 Configuración Técnica

### Capabilities de Appium

```ruby
caps = {
  platformName: "Android",
  deviceName: "Android Emulator",
  automationName: "UiAutomator2",
  appPackage: "com.mercadolibre",
  appActivity: "com.mercadolibre.splash.SplashActivity",
  noReset: true,
  autoGrantPermissions: true,
  newCommandTimeout: 300
}
```

### Dependencias Principales

- `appium_lib` (~> 16.0.0) - Cliente Appium para Ruby
- `selenium-webdriver` (>= 4.30) - WebDriver para automatización
- `appium_lib_core` (>= 11.0.2) - Core de Appium
- `rspec` (~> 3.13) - Framework de testing

## 📝 Notas Importantes

1. **Versión de la App**: Las pruebas están optimizadas para versiones recientes de Mercado Libre
2. **Selectores**: Los selectores pueden cambiar con actualizaciones de la app
3. **Performance**: Se recomienda usar un emulador con buenas especificaciones para mejor rendimiento
4. **Red**: Asegurar conexión estable a internet para que la app funcione correctamente
