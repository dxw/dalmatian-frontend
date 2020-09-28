class CreateMultipleEnvironmentVariables
  attr_accessor :infrastructure, :env_file, :service_name, :environment_name

  def initialize(infrastructure:, env_file:, service_name:, environment_name:)
    self.infrastructure = infrastructure
    self.env_file = env_file
    self.service_name = service_name
    self.environment_name = environment_name
  end

  def call
    results = []

    env_file.contents.each_pair do |key, value|
      environment_variable = EnvironmentVariable.new(
        name: key,
        value: value,
        service_name: service_name,
        environment_name: environment_name
      )
      result = CreateEnvironmentVariable.new(
        infrastructure: infrastructure,
        environment_variable: environment_variable
      ).call
      results << result
    end

    results
  end
end
