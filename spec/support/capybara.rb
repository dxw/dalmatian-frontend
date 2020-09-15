# frozen_string_literal: true

require "selenium/webdriver"

Capybara.asset_host = "http://localhost:3000"
Capybara.javascript_driver = :selenium_headless
Capybara.server = :puma, {Silent: true}
