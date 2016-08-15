require "capybara/rails"
Capybara.current_driver = :webkit
Capybara.javascript_driver = :webkit
Capybara.server_port = "8000"
Capybara.app_host = "http://#{Setting.host}:#{Capybara.server_port}"

Capybara::Webkit.configure(&:allow_unknown_urls)
