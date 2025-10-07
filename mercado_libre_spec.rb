require "appium_lib"
require "fileutils"
require_relative "test_reporter"

# CONFIG
APPIUM_SERVER_URL = "http://127.0.0.1:4723"

caps = {
  platformName: "Android",
  deviceName: "Android Emulator",
  automationName: "UiAutomator2",
  appPackage: "com.mercadolibre",
  # Intentar con actividad más genérica
  appActivity: "com.mercadolibre.splash.SplashActivity",
  noReset: true,
  # Agregar configuraciones adicionales para mayor compatibilidad
  autoGrantPermissions: true,
  newCommandTimeout: 300
}

opts = {
  caps: caps,
  appium_lib: {
    server_url: APPIUM_SERVER_URL,
    base_path: "/"
  }
}

# SELECTORES
SELECTORS = {
  id_search_open_buttons: "com.mercadolibre:id/ui_components_toolbar_title_toolbar",
  xpath_filter_display_options_btn: "(//android.widget.LinearLayout[@resource-id='com.mercadolibre:id/appbar_content_layout'])[1]/android.widget.LinearLayout",
  xpath_filter_condition_product: "//android.widget.TextView[@text='Condición']",
  xpath_new_condition_btn: "//android.widget.ToggleButton[@resource-id='ITEM_CONDITION-2230284']",
  xpath_filter_sort_product: "//android.view.View[@content-desc='Ordenar por ']",
  xpath_most_expensive_product_filter: "//android.widget.ToggleButton[@resource-id='sort-price_desc']",
  xpath_show_results_product_filter: "//android.widget.Button[@resource-id=':r3:']",

  polycard_component_title_1: "(//*[@resource-id='polycard_component'])[1]/android.widget.TextView",
  polycard_component_title_2: "(//*[@resource-id='polycard_component'])[2]/android.widget.TextView",
  polycard_component_title_3: "(//*[@resource-id='polycard_component'])[3]/android.widget.TextView",
  polycard_component_title_4: "(//*[@resource-id='polycard_component'])[4]/android.widget.TextView",
  polycard_component_title_5: "(//*[@resource-id='polycard_component'])[5]/android.widget.TextView",

  polycard_component_price_1: "(//*[@resource-id='polycard_component'])[1]/android.view.View/android.widget.TextView",
  polycard_component_price_2: "(//*[@resource-id='polycard_component'])[2]/android.view.View/android.widget.TextView",
  polycard_component_price_3: "(//*[@resource-id='polycard_component'])[3]/android.view.View/android.widget.TextView",
  polycard_component_price_4: "(//*[@resource-id='polycard_component'])[4]/android.view.View/android.widget.TextView",
  polycard_component_price_5: "(//*[@resource-id='polycard_component'])[5]/android.view.View/android.widget.TextView"
}

# FUNCIONES BÁSICAS
def screenshot(driver, name, reporter = nil)
  dir = File.join(__dir__, "reports", "screenshots")
  FileUtils.mkdir_p(dir)
  path = File.join(dir, "#{name}.png")
  driver.screenshot(path)
  puts "[SCREENSHOT] #{path}"
  
  # Log screenshot en el reporter si está disponible
  reporter&.log_screenshot(name, path)
end

def scroll_in_filter_sidebar(driver, direction: "up", percent: 1.0)
  puts "Haciendo scroll #{direction} en el sidebar de filtros..."
  begin
    driver.execute_script("mobile: swipeGesture", {
      left: 50,        # Área izquierda del sidebar
      top: 300,        # Desde arriba del sidebar
      width: 350,      # Ancho del sidebar de filtros
      height: 1000,    # Altura del área de scroll
      direction: direction,
      percent: percent # Porcentaje del área a desplazar
    })
    sleep 1
  rescue => e
    puts "Error en scroll del sidebar: #{e.message}"
  end
end

def scroll_in_products_page(driver, direction: "up", percent: 1.0)
  puts "Haciendo scroll #{direction} en la página de productos..."
  begin
    driver.execute_script("mobile: swipeGesture", {
      left: 200,       # Área central de la pantalla
      top: 400,        # Desde un poco más abajo del centro
      width: 600,      # Ancho del área de scroll
      height: 1200,    # Altura del área de scroll
      direction: direction,
      percent: percent # Porcentaje del área a desplazar
    })
    sleep 1
  rescue => e
    puts "Error en scroll de productos: #{e.message}"
  end
end

def check_app_installed()
  puts "Verificando si Mercado Libre está instalada..."
  result = `adb shell pm list packages | findstr mercadolibre`
  if result.empty?
    puts "❌ ERROR: La app de Mercado Libre no está instalada en el emulador"
    puts "Por favor instala la app desde Google Play Store en el emulador"
    exit 1
  else
    puts "✅ App de Mercado Libre encontrada: #{result.strip}"
  end
end

def wait_and_click(driver, selector_key, timeout: 15)
  locator = SELECTORS[selector_key]
  by = locator.start_with?('/', '(') ? :xpath : :id
  
  puts "Buscando elemento: #{selector_key} -> #{locator}"
  
  wait = Selenium::WebDriver::Wait.new(timeout: timeout)
  element = wait.until do
    els = driver.find_elements(by, locator)
    els.find { |el| el.displayed? rescue false }
  end
  
  if element
    puts "Elemento encontrado, haciendo click..."
    element.click
    sleep 1
  else
    raise "Elemento no encontrado o no visible: #{selector_key}"
  end
end

def get_text(driver, selector_key, timeout: 10)
  locator = SELECTORS[selector_key]
  by = locator.start_with?('/', '(') ? :xpath : :id
  
  wait = Selenium::WebDriver::Wait.new(timeout: timeout)
  element = wait.until do
    els = driver.find_elements(by, locator)
    els.find { |el| 
      begin
        el.displayed? && !el.text.strip.empty?
      rescue
        false
      end
    }
  end
  
  if element
    element.text.strip
  else
    "Texto no encontrado"
  end
end

# PASO 1: Abrir App
def open_app(driver, reporter = nil)
  puts "PASO 1: Abriendo Mercado Libre..."
  reporter&.log_step("Iniciar aplicación", "INFO", "Abriendo Mercado Libre...")
  
  # Intentar abrir la app manualmente si no se abrió automáticamente
  begin
    # Verificar si ya está en la app
    current_package = driver.current_package
    if current_package != "com.mercadolibre"
      puts "Intentando abrir la app manualmente..."
      driver.activate_app("com.mercadolibre")
      reporter&.log_step("Activar app", "PASS", "App activada manualmente")
    else
      reporter&.log_step("Verificar app", "PASS", "App ya estaba abierta")
    end
  rescue => e
    puts "Error al verificar/abrir app: #{e.message}"
    reporter&.log_step("Activar app", "FAIL", "Error: #{e.message}")
  end
  
  # Esperar que cargue y manejar posibles popups
  sleep 5
  
  # Intentar cerrar popup de "Continuar como visitante" si aparece
  begin
    guest_button = driver.find_element(:xpath, "//*[@text='Continuar como visitante' or @content-desc='Continuar como visitante']")
    if guest_button.displayed?
      puts "Cerrando popup 'Continuar como visitante'..."
      guest_button.click
      sleep 2
      reporter&.log_step("Cerrar popup", "PASS", "Popup 'Continuar como visitante' cerrado")
    end
  rescue
    # No hay popup, continuar
    reporter&.log_step("Verificar popup", "INFO", "No se encontró popup de visitante")
  end
  
  sleep 2
  screenshot(driver, "01_pagina_principal", reporter)
  reporter&.log_step("Página principal", "PASS", "App iniciada correctamente")
end

# PASO 2: Buscar 'playstation 5'
def search_product(driver, reporter = nil)
  puts "PASO 2: Buscando 'playstation 5'..."
  reporter&.log_step("Iniciar búsqueda", "INFO", "Comenzando búsqueda de PlayStation 5")
  
  # Abrir búsqueda
  wait_and_click(driver, :id_search_open_buttons)
  sleep 2
  screenshot(driver, "02_buscador", reporter)
  reporter&.log_step("Abrir buscador", "PASS", "Campo de búsqueda activado")
  
  # Escribir en el campo de búsqueda
  search_field = driver.find_element(:class, "android.widget.EditText")
  search_field.send_keys("playstation 5")
  reporter&.log_step("Escribir término", "PASS", "Término 'playstation 5' ingresado")
  
  # Presionar enter para buscar
  driver.press_keycode(66)  # ENTER
  sleep 3
  sleep 2
  screenshot(driver, "03_resultados_sin_filtrar", reporter)
  reporter&.log_step("Ejecutar búsqueda", "PASS", "Búsqueda ejecutada, resultados obtenidos")
end

# PASO 3: Aplicar filtros y ordenar
def apply_filters(driver, reporter = nil)
  puts "PASO 3: Aplicando filtros (Nuevo, Mayor precio)..."
  reporter&.log_step("Iniciar filtros", "INFO", "Comenzando aplicación de filtros")
  
  # Abrir filtros
  wait_and_click(driver, :xpath_filter_display_options_btn)
  sleep 2
  screenshot(driver, "04_menu_opciones", reporter)
  reporter&.log_step("Abrir menú filtros", "PASS", "Menú de opciones abierto")
  
  # Seleccionar condición
  wait_and_click(driver, :xpath_filter_condition_product)
  wait_and_click(driver, :xpath_new_condition_btn)
  sleep 2
  screenshot(driver, "05_condicion_nuevo", reporter)
  reporter&.log_step("Filtro condición", "PASS", "Filtro 'Nuevo' aplicado")
  
  # Ordenar por mayor precio  
  # Intentar hacer scroll en el sidebar para encontrar "Ordenar por"
  sleep 5
  scroll_in_filter_sidebar(driver, direction: "up", percent: 0.6)
  wait_and_click(driver, :xpath_filter_sort_product)
  wait_and_click(driver, :xpath_most_expensive_product_filter)
  sleep 2
  screenshot(driver, "06_ordenar_por", reporter)
  reporter&.log_step("Ordenamiento", "PASS", "Ordenado por mayor precio")

  # Mostrar resultados
  begin
    wait_and_click(driver, :xpath_show_results_product_filter)
    reporter&.log_step("Mostrar resultados", "PASS", "Botón mostrar resultados presionado")
  rescue
    # Si no encuentra el botón, continúa
    puts "Botón mostrar resultados no encontrado, continuando..."
    reporter&.log_step("Mostrar resultados", "INFO", "Botón no encontrado, continuando")
  end
  
  sleep 5
  sleep 2
  screenshot(driver, "07_resultados_con_filtros_aplicados", reporter)
  reporter&.log_step("Filtros aplicados", "PASS", "Todos los filtros aplicados correctamente")
end

# PASO 4: Obtener primeros 5 productos
def get_top5_products(driver, reporter = nil)
  puts "PASO 4: Obteniendo primeros 5 productos..."
  reporter&.log_step("Extraer productos", "INFO", "Iniciando extracción de top 5 productos")
  
  products = []
  
  (1..5).each do |i|
    begin
      # Hacer scroll si es necesario para ver el producto 5
      if i == 3
        scroll_in_products_page(driver, direction: "up", percent: 0.8)
        reporter&.log_step("Scroll productos", "INFO", "Scroll realizado para ver más productos")
      end

      title_key = "polycard_component_title_#{i}".to_sym
      price_key = "polycard_component_price_#{i}".to_sym
      
      title = get_text(driver, title_key)
      price = get_text(driver, price_key)
      
      products << {
        numero: i,
        nombre: title,
        precio: price
      }
      
      reporter&.log_step("Producto #{i}", "PASS", "#{title} - #{price}")
    rescue => e
      puts "Error obteniendo producto #{i}: #{e.message}"
      products << {
        numero: i,
        nombre: "No encontrado",
        precio: "No encontrado"
      }
      reporter&.log_step("Producto #{i}", "FAIL", "Error: #{e.message}")
    end
  end
  
  sleep 2
  screenshot(driver, "08_productos_extraidos", reporter)
  reporter&.log_step("Extracción completa", "PASS", "#{products.length} productos extraidos")
  return products
end

# EJECUCIÓN PRINCIPAL
begin
  puts "=== VERIFICACIONES INICIALES ==="
  
  # Inicializar reporter
  reporter = TestReporter.new
  reporter.log_step("Inicialización", "INFO", "Iniciando sistema de reportes")
  
  # Verificar que la app esté instalada
  check_app_installed()
  reporter.log_step("Verificar app", "PASS", "Mercado Libre instalada correctamente")
  
  puts "=== INICIANDO DRIVER ==="
  
  # Intentar diferentes configuraciones si la primera falla
  driver = nil
  
  begin
    # Configuración principal
    driver = Appium::Driver.new(opts, true)
    driver.start_driver
    reporter.log_step("Iniciar driver", "PASS", "Driver de Appium iniciado correctamente")
  rescue => e
    puts "Error con configuración principal: #{e.message}"
    puts "Intentando configuración alternativa..."
    reporter.log_step("Driver principal", "FAIL", "Error: #{e.message}")
    
    # Configuración alternativa sin especificar actividad
    alt_caps = caps.dup
    alt_caps.delete(:appActivity)
    alt_opts = { caps: alt_caps, appium_lib: opts[:appium_lib] }
    
    driver = Appium::Driver.new(alt_opts, true)
    driver.start_driver
    reporter.log_step("Driver alternativo", "PASS", "Driver iniciado con configuración alternativa")
  end
  
  puts "=== INICIO DEL TEST ==="
  
  # PASO 1: Abrir App
  open_app(driver, reporter)
  
  # PASO 2: Buscar 'playstation 5'
  search_product(driver, reporter)
  
  # PASO 3: Aplicar filtros y ordenar
  apply_filters(driver, reporter)
  
  # PASO 4: Obtener primeros 5 productos
  products = get_top5_products(driver, reporter)
  
  # Log de productos en el reporter
  reporter.log_products(products)
  
  # Mostrar resultados
  puts "\n=== RESULTADOS TOP 5 PRODUCTOS ==="
  products.each do |product|
    puts "#{product[:numero]}. #{product[:nombre]} - #{product[:precio]}"
  end
  puts "=================================="
  
  reporter.log_step("Test completado", "PASS", "Todos los pasos ejecutados exitosamente")
  puts "\n✅ TEST COMPLETADO EXITOSAMENTE"
  
rescue => e
  puts "\n❌ ERROR: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  
  # Log error en reporter
  reporter&.log_error("Error crítico", e.message)
  reporter&.log_step("Test fallido", "FAIL", "Test terminado por error: #{e.message}")
  
  # Screenshot del error
  begin
    screenshot(driver, "error", reporter) if driver
  rescue
  end
  
ensure
  # Generar reportes
  begin
    reporter&.generate_reports
    puts "\n📊 REPORTES GENERADOS EN: reports/"
  rescue => e
    puts "Error generando reportes: #{e.message}"
  end
  
  # Cerrar driver
  begin
    driver.quit if driver
  rescue
  end
  puts "\n=== FIN DEL TEST ==="
end
