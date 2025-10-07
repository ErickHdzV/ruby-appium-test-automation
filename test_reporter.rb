require "json"
require "erb"
require "time"

class TestReporter
  def initialize
    @test_start_time = Time.now
    @test_results = []
    @screenshots = []
    @errors = []
    @report_dir = File.join(__dir__, "reports")
    FileUtils.mkdir_p(@report_dir)
  end

  def log_step(step_name, status, details = "", screenshot_path = nil)
    @test_results << {
      step: step_name,
      status: status, # "PASS", "FAIL", "INFO"
      details: details,
      timestamp: Time.now,
      screenshot: screenshot_path
    }
    
    puts "[#{status}] #{step_name}: #{details}"
  end

  def log_screenshot(name, path)
    @screenshots << {
      name: name,
      path: path,
      timestamp: Time.now
    }
  end

  def log_error(error_message, error_details = "")
    @errors << {
      message: error_message,
      details: error_details,
      timestamp: Time.now
    }
  end

  def log_products(products)
    @products = products
  end

  def generate_reports
    @test_end_time = Time.now
    @test_duration = @test_end_time - @test_start_time
    
    generate_json_report
    generate_html_report
    generate_text_report
  end

  private

  def generate_json_report
    report_data = {
      test_info: {
        start_time: @test_start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_time: @test_end_time.strftime("%Y-%m-%d %H:%M:%S"),
        duration_seconds: @test_duration.round(2),
        total_steps: @test_results.length,
        passed_steps: @test_results.count { |r| r[:status] == "PASS" },
        failed_steps: @test_results.count { |r| r[:status] == "FAIL" },
        total_screenshots: @screenshots.length,
        total_errors: @errors.length
      },
      test_results: @test_results.map do |result|
        {
          step: result[:step],
          status: result[:status],
          details: result[:details],
          timestamp: result[:timestamp].strftime("%H:%M:%S"),
          screenshot: result[:screenshot]
        }
      end,
      screenshots: @screenshots.map do |ss|
        {
          name: ss[:name],
          path: ss[:path],
          timestamp: ss[:timestamp].strftime("%H:%M:%S")
        }
      end,
      errors: @errors,
      products: @products || []
    }

    json_path = File.join(@report_dir, "test_report_#{timestamp_file}.json")
    File.write(json_path, JSON.pretty_generate(report_data))
    puts "[REPORT] JSON generated: #{json_path}"
  end

  def generate_html_report
    html_template = <<~HTML
      <!DOCTYPE html>
      <html lang="es">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Reporte de Pruebas - Mercado Libre</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
              .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
              .header { text-align: center; border-bottom: 2px solid #3483fa; padding-bottom: 20px; margin-bottom: 30px; }
              .header h1 { color: #3483fa; margin: 0; }
              .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
              .summary-card { background: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center; border-left: 4px solid #3483fa; }
              .summary-card h3 { margin: 0 0 10px 0; color: #666; }
              .summary-card .value { font-size: 24px; font-weight: bold; color: #333; }
              .steps { margin-bottom: 30px; }
              .step { margin-bottom: 15px; padding: 15px; border-radius: 5px; border-left: 4px solid #ddd; }
              .step.PASS { border-left-color: #28a745; background-color: #f8fff9; }
              .step.FAIL { border-left-color: #dc3545; background-color: #fff8f8; }
              .step.INFO { border-left-color: #17a2b8; background-color: #f8feff; }
              .step-header { display: flex; justify-content: between; align-items: center; margin-bottom: 10px; }
              .step-name { font-weight: bold; font-size: 16px; }
              .step-status { padding: 4px 12px; border-radius: 15px; color: white; font-size: 12px; }
              .step-status.PASS { background-color: #28a745; }
              .step-status.FAIL { background-color: #dc3545; }
              .step-status.INFO { background-color: #17a2b8; }
              .step-details { color: #666; margin: 5px 0; }
              .step-time { color: #999; font-size: 12px; }
              .products { margin-bottom: 30px; }
              .products table { width: 100%; border-collapse: collapse; margin-top: 10px; }
              .products th, .products td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
              .products th { background-color: #f8f9fa; font-weight: bold; }
              .screenshots { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
              .screenshot { text-align: center; border: 1px solid #ddd; border-radius: 5px; padding: 10px; }
              .screenshot img { max-width: 100%; height: auto; border-radius: 5px; }
              .screenshot-name { font-weight: bold; margin-bottom: 10px; }
              .errors { background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; padding: 15px; margin-bottom: 20px; }
              .error { margin-bottom: 10px; padding: 10px; background: white; border-radius: 3px; }
          </style>
      </head>
      <body>
          <div class="container">
              <div class="header">
                  <h1>🧪 Reporte de Pruebas Automatizadas</h1>
                  <h2>Mercado Libre - Búsqueda PlayStation 5</h2>
                  <p>Generado el <%= @test_end_time.strftime("%d/%m/%Y a las %H:%M:%S") %></p>
              </div>

              <div class="summary">
                  <div class="summary-card">
                      <h3>Duración Total</h3>
                      <div class="value"><%= (@test_duration / 60).round(1) %> min</div>
                  </div>
                  <div class="summary-card">
                      <h3>Pasos Ejecutados</h3>
                      <div class="value"><%= @test_results.length %></div>
                  </div>
                  <div class="summary-card">
                      <h3>Éxitos</h3>
                      <div class="value" style="color: #28a745;"><%= @test_results.count { |r| r[:status] == "PASS" } %></div>
                  </div>
                  <div class="summary-card">
                      <h3>Fallos</h3>
                      <div class="value" style="color: #dc3545;"><%= @test_results.count { |r| r[:status] == "FAIL" } %></div>
                  </div>
                  <div class="summary-card">
                      <h3>Screenshots</h3>
                      <div class="value"><%= @screenshots.length %></div>
                  </div>
              </div>

              <% if @errors.any? %>
              <div class="errors">
                  <h3>⚠️ Errores Encontrados</h3>
                  <% @errors.each do |error| %>
                  <div class="error">
                      <strong><%= error[:message] %></strong><br>
                      <small><%= error[:details] %></small><br>
                      <small>Tiempo: <%= error[:timestamp].strftime("%H:%M:%S") %></small>
                  </div>
                  <% end %>
              </div>
              <% end %>

              <div class="steps">
                  <h3>📋 Pasos Ejecutados</h3>
                  <% @test_results.each do |result| %>
                  <div class="step <%= result[:status] %>">
                      <div class="step-header">
                          <span class="step-name"><%= result[:step] %></span>
                          <span class="step-status <%= result[:status] %>"><%= result[:status] %></span>
                      </div>
                      <div class="step-details"><%= result[:details] %></div>
                      <div class="step-time">⏰ <%= result[:timestamp].strftime("%H:%M:%S") %></div>
                  </div>
                  <% end %>
              </div>

              <% if @products && @products.any? %>
              <div class="products">
                  <h3>🎮 Productos Encontrados</h3>
                  <table>
                      <thead>
                          <tr>
                              <th>#</th>
                              <th>Nombre del Producto</th>
                              <th>Precio</th>
                          </tr>
                      </thead>
                      <tbody>
                          <% @products.each do |product| %>
                          <tr>
                              <td><%= product[:numero] %></td>
                              <td><%= product[:nombre] %></td>
                              <td><%= product[:precio] %></td>
                          </tr>
                          <% end %>
                      </tbody>
                  </table>
              </div>
              <% end %>

              <% if @screenshots.any? %>
              <div>
                  <h3>📸 Screenshots Capturados</h3>
                  <div class="screenshots">
                      <% @screenshots.each do |screenshot| %>
                      <div class="screenshot">
                          <div class="screenshot-name"><%= screenshot[:name] %></div>
                          <img src="screenshots/<%= File.basename(screenshot[:path]) %>" alt="<%= screenshot[:name] %>">
                          <div class="step-time">⏰ <%= screenshot[:timestamp].strftime("%H:%M:%S") %></div>
                      </div>
                      <% end %>
                  </div>
              </div>
              <% end %>
          </div>
      </body>
      </html>
    HTML

    renderer = ERB.new(html_template)
    html_content = renderer.result(binding)
    
    html_path = File.join(@report_dir, "test_report_#{timestamp_file}.html")
    File.write(html_path, html_content)
    puts "[REPORT] HTML generated: #{html_path}"
  end

  def generate_text_report
    text_content = <<~TEXT
      ==========================================
      REPORTE DE PRUEBAS AUTOMATIZADAS
      ==========================================
      Aplicación: Mercado Libre
      Escenario: Búsqueda PlayStation 5
      Fecha: #{@test_end_time.strftime("%d/%m/%Y")}
      Hora: #{@test_end_time.strftime("%H:%M:%S")}
      
      RESUMEN EJECUTIVO:
      ==========================================
      Duración total: #{(@test_duration / 60).round(1)} minutos
      Pasos ejecutados: #{@test_results.length}
      Éxitos: #{@test_results.count { |r| r[:status] == "PASS" }}
      Fallos: #{@test_results.count { |r| r[:status] == "FAIL" }}
      Screenshots: #{@screenshots.length}
      Errores: #{@errors.length}
      
      DETALLE DE PASOS:
      ==========================================
    TEXT

    @test_results.each_with_index do |result, index|
      text_content += sprintf("%-3d. [%-4s] %-30s %s\n", 
        index + 1, 
        result[:status], 
        result[:step], 
        result[:details]
      )
    end

    if @products && @products.any?
      text_content += "\n\nPRODUCTOS ENCONTRADOS:\n"
      text_content += "==========================================\n"
      @products.each do |product|
        text_content += sprintf("%-3d. %-50s %s\n", 
          product[:numero], 
          product[:nombre], 
          product[:precio]
        )
      end
    end

    if @errors.any?
      text_content += "\n\nERRORES:\n"
      text_content += "==========================================\n"
      @errors.each_with_index do |error, index|
        text_content += "#{index + 1}. #{error[:message]}\n"
        text_content += "   #{error[:details]}\n" if error[:details] != ""
        text_content += "   Tiempo: #{error[:timestamp].strftime("%H:%M:%S")}\n\n"
      end
    end

    text_content += "\n\nSCREENSHOTS GENERADOS:\n"
    text_content += "==========================================\n"
    @screenshots.each do |screenshot|
      text_content += "#{screenshot[:name]} - #{screenshot[:timestamp].strftime("%H:%M:%S")}\n"
    end

    text_content += "\n\n==========================================\n"
    text_content += "Fin del reporte\n"
    text_content += "==========================================\n"

    text_path = File.join(@report_dir, "test_report_#{timestamp_file}.txt")
    File.write(text_path, text_content)
    puts "[REPORT] TXT generated: #{text_path}"
  end

  def timestamp_file
    @test_start_time.strftime("%Y%m%d_%H%M%S")
  end
end