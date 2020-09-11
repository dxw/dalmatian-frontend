class EnvironmentVariable
  include ActiveModel::Model

  attr_accessor :name, :value, :service_name, :environment_name
end
