# frozen_string_literal: true

RSpec.configure do |config|
  DatabaseCleaner[:mongoid].strategy = [:deletion, except: []]
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
