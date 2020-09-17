class FindInfrastructureVariables
  include AwsClientWrapper

  attr_writer :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}

    infrastructure.environments.each do |environment_name, _blob|
      results[environment_name] = fetch_environment_variables(
        environment_name: environment_name
      )
    end

    results
  end

  private

  attr_reader :infrastructure

  def fetch_environment_variables(environment_name:)
    path = "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{environment_name}/"

    parameters = aws_ssm_client.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    ).parameters

    parameters.each { |p| p.name = File.basename(p.name) }
  end
end
