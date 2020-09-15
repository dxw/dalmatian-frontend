# frozen_string_literal: true

require "selenium/webdriver"

javascript_driver = ENV["CI"].present? ? :selenium_headless : :selenium_chrome_headless

Capybara.asset_host = "http://localhost:3000"
Capybara.always_include_port = true
Capybara.default_driver = :rack_test
Capybara.javascript_driver = javascript_driver
Capybara.server = :puma, {Silent: true}
