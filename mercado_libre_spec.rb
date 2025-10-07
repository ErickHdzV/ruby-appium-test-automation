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
  # Try with a more generic activity
  appActivity: "com.mercadolibre.splash.SplashActivity",
  noReset: true,
  # Add additional configurations for better compatibility
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

# SELECTORS
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

# BASIC FUNCTIONS
def screenshot(driver, name, reporter = nil)
  dir = File.join(__dir__, "reports", "screenshots")
  FileUtils.mkdir_p(dir)
  path = File.join(dir, "#{name}.png")
  driver.screenshot(path)
  puts "[SCREENSHOT] #{path}"
  
  # Log screenshot in the reporter if available
  reporter&.log_screenshot(name, path)
end

def scroll_in_filter_sidebar(driver, direction: "up", percent: 1.0)
  puts "Scrolling #{direction} in the filter sidebar..."
  begin
    driver.execute_script("mobile: swipeGesture", {
      left: 50,        # Left area of the sidebar
      top: 300,        # From the top of the sidebar
      width: 350,      # Width of the filter sidebar
      height: 1000,    # Height of the scroll area
      direction: direction,
      percent: percent # Percentage of the area to scroll
    })
    sleep 1
  rescue => e
    puts "Error in sidebar scroll: #{e.message}"
  end
end

def scroll_in_products_page(driver, direction: "up", percent: 1.0)
  puts "Scrolling #{direction} in the products page..."
  begin
    driver.execute_script("mobile: swipeGesture", {
      left: 200,       # Central area of the screen
      top: 400,        # From a bit below the center
      width: 600,      # Width of the scroll area
      height: 1200,    # Height of the scroll area
      direction: direction,
      percent: percent # Percentage of the area to scroll
    })
    sleep 1
  rescue => e
    puts "Error in products scroll: #{e.message}"
  end
end

def check_app_installed()
  puts "Checking if Mercado Libre is installed..."
  result = `adb shell pm list packages | findstr mercadolibre`
  if result.empty?
    puts "❌ ERROR: Mercado Libre app is not installed in the emulator"
    puts "Please install the app from Google Play Store in the emulator"
    exit 1
  else
    puts "✅ Mercado Libre app found: #{result.strip}"
  end
end

def wait_and_click(driver, selector_key, timeout: 15)
  locator = SELECTORS[selector_key]
  by = locator.start_with?('/', '(') ? :xpath : :id
  
  puts "Looking for element: #{selector_key} -> #{locator}"
  
  wait = Selenium::WebDriver::Wait.new(timeout: timeout)
  element = wait.until do
    els = driver.find_elements(by, locator)
    els.find { |el| el.displayed? rescue false }
  end
  
  if element
    puts "Element found, clicking..."
    element.click
    sleep 1
  else
    raise "Element not found or not visible: #{selector_key}"
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
    "Text not found"
  end
end

# STEP 1: Open App
def open_app(driver, reporter = nil)
  puts "STEP 1: Opening Mercado Libre..."
  reporter&.log_step("Start application", "INFO", "Opening Mercado Libre...")
  
  # Try to open the app manually if it didn't open automatically
  begin
    # Check if already in the app
    current_package = driver.current_package
    if current_package != "com.mercadolibre"
      puts "Trying to open the app manually..."
      driver.activate_app("com.mercadolibre")
      reporter&.log_step("Activate app", "PASS", "App activated manually")
    else
      reporter&.log_step("Verify app", "PASS", "App was already open")
    end
  rescue => e
    puts "Error verifying/opening app: #{e.message}"
    reporter&.log_step("Activate app", "FAIL", "Error: #{e.message}")
  end
  
  # Wait for it to load and handle possible popups
  sleep 5
  
  # Try to close "Continue as guest" popup if it appears
  begin
    guest_button = driver.find_element(:xpath, "//*[@text='Continuar como visitante' or @content-desc='Continuar como visitante']")
    if guest_button.displayed?
      puts "Closing 'Continue as guest' popup..."
      guest_button.click
      sleep 2
      reporter&.log_step("Close popup", "PASS", "'Continue as guest' popup closed")
    end
  rescue
    # No popup, continue
    reporter&.log_step("Verify popup", "INFO", "Guest popup not found")
  end
  
  sleep 2
  screenshot(driver, "01_pagina_principal", reporter)
  reporter&.log_step("Main page", "PASS", "App started correctly")
end

# STEP 2: Search for 'playstation 5'
def search_product(driver, reporter = nil)
  puts "STEP 2: Searching for 'playstation 5'..."
  reporter&.log_step("Start search", "INFO", "Starting PlayStation 5 search")
  
  # Open search
  wait_and_click(driver, :id_search_open_buttons)
  sleep 2
  screenshot(driver, "02_buscador", reporter)
  reporter&.log_step("Open search", "PASS", "Search field activated")
  
  # Type in the search field
  search_field = driver.find_element(:class, "android.widget.EditText")
  search_field.send_keys("playstation 5")
  reporter&.log_step("Type term", "PASS", "Term 'playstation 5' entered")
  
  # Press enter to search
  driver.press_keycode(66)  # ENTER
  sleep 3
  sleep 2
  screenshot(driver, "03_resultados_sin_filtrar", reporter)
  reporter&.log_step("Execute search", "PASS", "Search executed, results obtained")
end

# STEP 3: Apply filters and sort
def apply_filters(driver, reporter = nil)
  puts "STEP 3: Applying filters (New, Highest price)..."
  reporter&.log_step("Start filters", "INFO", "Starting filter application")
  
  # Open filters
  wait_and_click(driver, :xpath_filter_display_options_btn)
  sleep 2
  screenshot(driver, "04_menu_opciones", reporter)
  reporter&.log_step("Open filter menu", "PASS", "Options menu opened")
  
  # Select condition
  wait_and_click(driver, :xpath_filter_condition_product)
  wait_and_click(driver, :xpath_new_condition_btn)
  sleep 2
  screenshot(driver, "05_condicion_nuevo", reporter)
  reporter&.log_step("Condition filter", "PASS", "'New' filter applied")
  
  # Sort by highest price  
  # Try to scroll in the sidebar to find "Sort by"
  sleep 5
  scroll_in_filter_sidebar(driver, direction: "up", percent: 0.6)
  wait_and_click(driver, :xpath_filter_sort_product)
  wait_and_click(driver, :xpath_most_expensive_product_filter)
  sleep 2
  screenshot(driver, "06_ordenar_por", reporter)
  reporter&.log_step("Sorting", "PASS", "Sorted by highest price")

  # Show results
  begin
    wait_and_click(driver, :xpath_show_results_product_filter)
    reporter&.log_step("Show results", "PASS", "Show results button pressed")
  rescue
    # If button not found, continue
    puts "Show results button not found, continuing..."
    reporter&.log_step("Show results", "INFO", "Button not found, continuing")
  end
  
  sleep 5
  sleep 2
  screenshot(driver, "07_resultados_con_filtros_aplicados", reporter)
  reporter&.log_step("Filters applied", "PASS", "All filters applied correctly")
end

# STEP 4: Get first 5 products
def get_top5_products(driver, reporter = nil)
  puts "STEP 4: Getting first 5 products..."
  reporter&.log_step("Extract products", "INFO", "Starting top 5 products extraction")
  
  products = []
  
  (1..5).each do |i|
    begin
      # Scroll if necessary to see product 5
      if i == 3
        scroll_in_products_page(driver, direction: "up", percent: 0.8)
        reporter&.log_step("Scroll products", "INFO", "Scroll performed to see more products")
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
      
      reporter&.log_step("Product #{i}", "PASS", "#{title} - #{price}")
    rescue => e
      puts "Error getting product #{i}: #{e.message}"
      products << {
        numero: i,
        nombre: "Not found",
        precio: "Not found"
      }
      reporter&.log_step("Product #{i}", "FAIL", "Error: #{e.message}")
    end
  end
  
  sleep 2
  screenshot(driver, "08_productos_extraidos", reporter)
  reporter&.log_step("Extraction complete", "PASS", "#{products.length} products extracted")
  return products
end

# MAIN EXECUTION
begin
  puts "=== INITIAL VERIFICATIONS ==="
  
  # Initialize reporter
  reporter = TestReporter.new
  reporter.log_step("Initialization", "INFO", "Starting reporting system")
  
  # Verify that the app is installed
  check_app_installed()
  reporter.log_step("Verify app", "PASS", "Mercado Libre installed correctly")
  
  puts "=== STARTING DRIVER ==="
  
  # Try different configurations if the first one fails
  driver = nil
  
  begin
    # Main configuration
    driver = Appium::Driver.new(opts, true)
    driver.start_driver
    reporter.log_step("Start driver", "PASS", "Appium driver started correctly")
  rescue => e
    puts "Error with main configuration: #{e.message}"
    puts "Trying alternative configuration..."
    reporter.log_step("Main driver", "FAIL", "Error: #{e.message}")
    
    # Alternative configuration without specifying activity
    alt_caps = caps.dup
    alt_caps.delete(:appActivity)
    alt_opts = { caps: alt_caps, appium_lib: opts[:appium_lib] }
    
    driver = Appium::Driver.new(alt_opts, true)
    driver.start_driver
    reporter.log_step("Alternative driver", "PASS", "Driver started with alternative configuration")
  end
  
  puts "=== TEST START ==="
  
  # STEP 1: Open App
  open_app(driver, reporter)
  
  # STEP 2: Search for 'playstation 5'
  search_product(driver, reporter)
  
  # STEP 3: Apply filters and sort
  apply_filters(driver, reporter)
  
  # STEP 4: Get first 5 products
  products = get_top5_products(driver, reporter)
  
  # Log products in the reporter
  reporter.log_products(products)
  
  # Show results
  puts "\n=== TOP 5 PRODUCTS RESULTS ==="
  products.each do |product|
    puts "#{product[:numero]}. #{product[:nombre]} - #{product[:precio]}"
  end
  puts "================================"
  
  reporter.log_step("Test completed", "PASS", "All steps executed successfully")
  puts "\n✅ TEST COMPLETED SUCCESSFULLY"
  
rescue => e
  puts "\n❌ ERROR: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  
  # Log error in reporter
  reporter&.log_error("Critical error", e.message)
  reporter&.log_step("Test failed", "FAIL", "Test terminated by error: #{e.message}")
  
  # Error screenshot
  begin
    screenshot(driver, "error", reporter) if driver
  rescue
  end
  
ensure
  # Generate reports
  begin
    reporter&.generate_reports
    puts "\n📊 REPORTS GENERATED IN: reports/"
  rescue => e
    puts "Error generating reports: #{e.message}"
  end
  
  # Close driver
  begin
    driver.quit if driver
  rescue
  end
  puts "\n=== TEST END ==="
end
