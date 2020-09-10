class FindEnvironmentVariables
  include AwsClientWrapper

  attr_writer :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}

    infrastructure.services.each do |service|
      service_name = service["name"]
      results[service_name] = {}

      infrastructure.environments.each do |environment_name, _blob|
        results[service_name][environment_name] = fetch_environment_variables(
          service_name: service_name, environment_name: environment_name
        )
      end
    end

    results
  end

  private

  attr_reader :infrastructure

  def fetch_environment_variables(service_name:, environment_name:)
    path = "/#{infrastructure.identifier}/#{service_name}/#{environment_name}/"

    parameters = aws_ssm_client.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    ).parameters

    parameters.each { |p| p.name = File.basename(p.name) }
  end
end
