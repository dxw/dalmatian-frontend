class FindInfrastructureVariables
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    results = {}

    infrastructure.environments.each do |environment_name, _blob|
      path = infrastructure_variable_path(environment_name: environment_name)
      results[environment_name] = GetAwsParameter.new(aws_ssm_client: aws_ssm_client, path: path).call
    end

    results
  end

  private

  def aws_ssm_client
    @aws_ssm_client ||= SSMClientForCoreAwsAccount.new.call
  end

  def infrastructure_variable_path(environment_name:)
    "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{environment_name}/"
  end
end
