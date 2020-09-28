class DeleteEnvironmentVariable
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(environment_variable:)
    full_name = "#{infrastructure.identifier}/#{environment_variable.full_aws_name}"

    DeleteAwsParameter.new(aws_ssm_client: aws_ssm_client, infrastructure: infrastructure).call(path: full_name)
  end

  private

  def aws_ssm_client
    ClientForInfrastructureAwsAccount.new(infrastructure: infrastructure).call
  end
end
