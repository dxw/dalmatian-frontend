# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "2.6.3"

gem "aws-sdk-ssm", "~> 1.102"
gem "aws-sdk-codepipeline", "~> 1.38.0"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", ">= 4.3.1"
gem "coffee-rails", "~> 5.0"
gem "haml-rails"
gem "high_voltage"
gem "jbuilder", "~> 2.10"
gem "jquery-rails"
gem "pg"
gem "mini_racer"
gem "mongoid"
gem "puma", "~> 5.1"
gem "rollbar"
gem "rails", "~> 6.0.3"
gem "sass-rails", "~> 6.0"
gem "simple_form"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "uglifier", ">= 1.3.0"

group :development do
  gem "better_errors", "< 2.9.2"
  gem "listen", ">= 3.0.5", "< 3.4"
  gem "html2haml"
  gem "rails_layout"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "climate_control"
  gem "database_cleaner"
  gem "launchy"
  gem "geckodriver-helper"
  gem "selenium-webdriver"
  gem "simplecov", "~> 0.21"
  gem "simplecov-lcov"
end

group :development, :test do
  gem "brakeman"
  gem "bullet"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry"
  gem "rspec-rails"
  gem "standard"
end
