#!/usr/bin/env ruby

require_relative "test_reporter"
require "json"

# Script para generar reportes desde datos existentes
class ReportGenerator
  def self.generate_sample_report
    puts "Generando reporte de ejemplo..."
    
    reporter = TestReporter.new
    
    # Simular algunos datos de prueba
    reporter.log_step("Verificar app", "PASS", "Mercado Libre instalada correctamente")
    reporter.log_step("Iniciar driver", "PASS", "Driver de Appium iniciado")
    reporter.log_step("Abrir aplicación", "PASS", "App iniciada correctamente")
    reporter.log_step("Abrir buscador", "PASS", "Campo de búsqueda activado")
    reporter.log_step("Ejecutar búsqueda", "PASS", "Búsqueda ejecutada, resultados obtenidos")
    reporter.log_step("Abrir menú filtros", "PASS", "Menú de opciones abierto")
    reporter.log_step("Filtro condición", "PASS", "Filtro 'Nuevo' aplicado")
    reporter.log_step("Ordenamiento", "PASS", "Ordenado por mayor precio")
    reporter.log_step("Extraer productos", "PASS", "5 productos extraidos")
    
    # Productos de ejemplo
    products = [
      { numero: 1, nombre: "PlayStation 5 Console", precio: "$499.99" },
      { numero: 2, nombre: "PlayStation 5 Digital Edition", precio: "$399.99" },
      { numero: 3, nombre: "PlayStation 5 Bundle", precio: "$699.99" },
      { numero: 4, nombre: "PlayStation 5 + Spider-Man", precio: "$559.99" },
      { numero: 5, nombre: "PlayStation 5 Pro", precio: "$799.99" }
    ]
    
    reporter.log_products(products)
    
    # Screenshots de ejemplo
    reporter.log_screenshot("01_pagina_principal", "screenshots/01_pagina_principal.png")
    reporter.log_screenshot("02_buscador", "screenshots/02_buscador.png")
    reporter.log_screenshot("03_resultados_sin_filtrar", "screenshots/03_resultados_sin_filtrar.png")
    
    reporter.generate_reports
    puts "✅ Reportes de ejemplo generados en: reports/"
  end
  
  def self.list_available_reports
    reports_dir = File.join(__dir__, "reports")
    return unless Dir.exist?(reports_dir)
    
    puts "📊 REPORTES DISPONIBLES:"
    puts "=" * 50
    
    json_files = Dir.glob(File.join(reports_dir, "test_report_*.json")).sort.reverse
    html_files = Dir.glob(File.join(reports_dir, "test_report_*.html")).sort.reverse
    txt_files = Dir.glob(File.join(reports_dir, "test_report_*.txt")).sort.reverse
    
    if json_files.empty?
      puts "No se encontraron reportes."
      puts "Ejecuta las pruebas para generar reportes."
      return
    end
    
    puts "JSON Reports:"
    json_files.each_with_index do |file, index|
      timestamp = File.basename(file, ".json").sub("test_report_", "")
      formatted_time = DateTime.strptime(timestamp, "%Y%m%d_%H%M%S").strftime("%d/%m/%Y %H:%M:%S")
      puts "  #{index + 1}. #{formatted_time} - #{file}"
    end
    
    puts "\nHTML Reports:"
    html_files.each_with_index do |file, index|
      timestamp = File.basename(file, ".html").sub("test_report_", "")
      formatted_time = DateTime.strptime(timestamp, "%Y%m%d_%H%M%S").strftime("%d/%m/%Y %H:%M:%S")
      puts "  #{index + 1}. #{formatted_time} - #{file}"
    end
    
    puts "\nTXT Reports:"
    txt_files.each_with_index do |file, index|
      timestamp = File.basename(file, ".txt").sub("test_report_", "")
      formatted_time = DateTime.strptime(timestamp, "%Y%m%d_%H%M%S").strftime("%d/%m/%Y %H:%M:%S")
      puts "  #{index + 1}. #{formatted_time} - #{file}"
    end
    
    puts "\n💡 Para abrir un reporte HTML:"
    puts "   - Navega a la carpeta reports/"
    puts "   - Abre el archivo .html en tu navegador"
    puts "=" * 50
  end
end

# Menú principal
if ARGV.length == 0
  puts "GENERADOR DE REPORTES - Mercado Libre Testing"
  puts "=" * 50
  puts "Opciones disponibles:"
  puts "  ruby report_generator.rb list    - Listar reportes existentes"
  puts "  ruby report_generator.rb sample  - Generar reporte de ejemplo"
  puts "  ruby report_generator.rb help    - Mostrar ayuda"
else
  case ARGV[0].downcase
  when "list", "ls"
    ReportGenerator.list_available_reports
  when "sample", "example"
    ReportGenerator.generate_sample_report
  when "help", "h", "--help"
    puts "AYUDA - Generador de Reportes"
    puts "=" * 50
    puts "Este script te permite:"
    puts "• Listar todos los reportes generados por las pruebas"
    puts "• Generar un reporte de ejemplo para ver el formato"
    puts ""
    puts "Los reportes se generan automáticamente cuando ejecutas:"
    puts "  ruby mercado_libre_spec.rb"
    puts ""
    puts "Formatos de reporte disponibles:"
    puts "• JSON - Para procesamiento automático"
    puts "• HTML - Para visualización en navegador"
    puts "• TXT - Para lectura rápida en consola"
  else
    puts "❌ Opción no reconocida: #{ARGV[0]}"
    puts "Usa: ruby report_generator.rb help"
  end
end