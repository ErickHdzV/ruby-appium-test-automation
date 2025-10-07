# Mercado Libre Mobile Testing - Ruby Appium

### Author

Erick Hernandez Velazco [github](https://github.com/ErickHdzV)
Email: erick.hv@codebyerick.com

This project contains automated tests for the Mercado Libre mobile application using Ruby and Appium. The tests verify search, filtering, and product sorting functionality.

## 📋 Prerequisites

### Operating System

- **Windows** (configured for Windows PowerShell)

### Required Software

#### 1. Ruby

- **Required version**: Ruby 3.4.6 or higher
- Download from: https://rubyinstaller.org/
- Verify installation: `ruby --version`

#### 2. Android SDK and ADB

- **Android SDK** installed (can be through Android Studio)
- **ADB** available in PATH
- Verify: `adb --version`

#### 3. Appium Server

- **Node.js** (version 14 or higher)
- **Appium** installed globally

```bash
npm install -g appium
npm install -g @appium/doctor
```

#### 4. Appium Drivers

```bash
appium driver install uiautomator2
```

#### 5. Android Emulator or Physical Device

- **Android Emulator** configured and running
- Or **physical Android device** with USB debugging enabled

## 📱 Device/Emulator Configuration

### Emulator Configuration

1. Create an Android emulator with:

- **Android Studio** > AVD Manager > Create Virtual Device
- **API Level**: 28 or higher
- **Target**: Google APIs
- **ABI**: x86_64 (recommended for performance)

2. Start the emulator:

```bash
emulator -avd <emulator_name>
```

3. Verify the emulator is connected:

```bash
adb devices
```

### Mercado Libre Application

- **IMPORTANT**: The Mercado Libre application must be installed on the emulator/device
- Download from Google Play Store on the emulator
- Package name: `com.mercadolibre`

## 🛠️ Project Configuration

### 1. Clone/Get the Project

```bash
git clone https://github.com/ErickHdzV/ruby-appium-test-automation.git
cd ruby-appium-test-automation
```

### 2. Install Ruby Dependencies

```bash
bundle install
```

### 3. Verify Appium Configuration

```bash
appium-doctor --android
```

## 🚀 Test Execution

### 1. Start Appium Server

In a separate terminal:

```bash
appium --use-plugins=inspector --allow-cors
```

The server will start at: `http://127.0.0.1:4723`

### 2. Verify Emulator/Device is Connected (optional)

```bash
adb devices
```

### 3. Run the Test

```bash
ruby mercado_libre_spec.rb
```

## 📊 Test Functionality

### Main Test Scenario

1. **Open application** Mercado Libre
2. **Search** "playstation 5"
3. **Apply filters**:
   - Condition: New
   - Sort by: Highest price
4. **Extract information** from the first 5 products displayed
5. **Generate reports** with screenshots

## 📈 Report Visualization

### Open HTML Report

1. Navigate to the `reports/` folder
2. Find the most recent file: `test_report_YYYYMMDD_HHMMSS.html`
3. Double-click to open in your default browser
4. The report includes screenshots, metrics, and complete details

### View Report History

```bash
ruby report_generator.rb list
```

## 🎯 Report Metrics

The reports provide the following metrics:

- **Total execution time**
- **Number of steps executed**
- **Successful vs failed steps**
- **Number of screenshots captured**
- **Products found and extracted**
- **Detailed errors with timestamps**

## 📁 Project Structure

```
mercado-libre-ruby/
├── mercado_libre_spec.rb   # Main test file
├── test_reporter.rb        # Report generation system
├── report_generator.rb     # Report management utility
├── Gemfile                 # Ruby dependencies
├── Gemfile.lock           # Specific dependency versions
├── README.md              # This file
└── reports/
    ├── screenshots/       # Generated screenshots
    │   ├── 01_main_page.png
    │   ├── 02_search_box.png
    │   ├── 03_results_unfiltered.png
    │   ├── 04_options_menu.png
    │   ├── 05_new_condition.png
    │   ├── 06_sort_by.png
    │   ├── 07_results_with_filters_applied.png
    │   ├── 08_products_extracted.png
    │   └── error.png (if an error occurs)
    ├── test_report_YYYYMMDD_HHMMSS.json  # JSON format report
    ├── test_report_YYYYMMDD_HHMMSS.html  # Visual HTML report
    └── test_report_YYYYMMDD_HHMMSS.txt   # Plain text report
```

## 📊 Reporting System

### Automatic Reports

The tests automatically generate 3 types of reports:

#### 1. **HTML Report** (Recommended for visualization)

- Complete visual interface with graphics
- Integrated screenshots
- Executive summary
- Step-by-step details
- **Location**: `reports/test_report_YYYYMMDD_HHMMSS.html`

#### 2. **JSON Report** (For automated processing)

- Structured data for analysis
- Integration with other tools
- **Location**: `reports/test_report_YYYYMMDD_HHMMSS.json`

#### 3. **TXT Report** (For quick reading)

- Plain text format
- Concise results summary
- **Location**: `reports/test_report_YYYYMMDD_HHMMSS.txt`

### Report Management

#### List existing reports:

```bash
ruby report_generator.rb list
```

#### Generate example report:

```bash
ruby report_generator.rb sample
```

#### View generator help:

```bash
ruby report_generator.rb help
```

### Report Content

The reports include:

- ✅ **Executive summary** with success/failure metrics
- ⏱️ **Total duration** of the test
- 📝 **Detailed log** of each executed step
- 📸 **Screenshots** of each stage of the process
- 🎮 **List of products** found with prices
- ❌ **Detailed errors** if failures occur
- 📊 **Execution statistics**

## 🔧 Technical Configuration

### Appium Capabilities

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

### Main Dependencies

- `appium_lib` (~> 16.0.0) - Appium client for Ruby
- `selenium-webdriver` (>= 4.30) - WebDriver for automation
- `appium_lib_core` (>= 11.0.2) - Appium core
- `rspec` (~> 3.13) - Testing framework

## 📝 Important Notes

1. **App Version**: The tests are optimized for recent versions of Mercado Libre
2. **Selectors**: Selectors may change with app updates
3. **Performance**: It is recommended to use an emulator with good specifications for better performance

### Timeout Error

- Increase timeouts in the code if the network is slow
- Verify that the emulator has sufficient resources
- Ensure the app is not loading additional elements

### Automatic Screenshots

The tests automatically generate screenshots at key points:

- When opening the application
- After performing the search
- After applying filters
- After extracting products
- In case of error
