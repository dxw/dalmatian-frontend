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
        path = environment_variable_path(service_name: service_name, environment_name: environment_name)
        results[service_name][environment_name] = GetAwsParameter.new(aws_ssm_client: aws_ssm_client, path: path).call
      end
    end

    results
  end

  private

  attr_reader :infrastructure

  def aws_ssm_client
    @aws_ssm_client ||= SSMClientForInfrastructureAwsAccount.new(infrastructure: infrastructure).call
  end

  def environment_variable_path(service_name:, environment_name:)
    "/#{infrastructure.identifier}/#{service_name}/#{environment_name}/"
  end
end
