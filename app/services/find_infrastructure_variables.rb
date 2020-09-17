class FindInfrastructureVariables
  attr_writer :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}

    infrastructure.environments.each do |environment_name, _blob|
      path = infrastructure_variable_path(environment_name: environment_name)
      results[environment_name] = GetAwsParameter.new(infrastructure: infrastructure, path: path).call
    end

    results
  end

  private

  attr_reader :infrastructure

  def infrastructure_variable_path(environment_name:)
    "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{environment_name}/"
  end
end
