class DeleteInfrastructureVariable
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(infrastructure_variable:)
    full_name = "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{infrastructure_variable.environment_name}/#{infrastructure_variable.name}"

    result = DeleteAwsParameter.new(aws_ssm_client: aws_ssm_client, infrastructure: infrastructure).call(path: full_name)
    result
  end

  private

  def aws_ssm_client
    ClientForCoreAwsAccount.new.call
  end
end
