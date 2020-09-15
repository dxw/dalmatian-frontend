class DeleteEnvironmentVariable
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(environment_variable:)
    full_name = "#{infrastructure.identifier}/#{environment_variable.full_aws_name}"

    begin
      aws_ssm_client.delete_parameter(name: full_name)
      Result.new(true)
    rescue Aws::SSM::Errors::ParameterNotFound => error
      Result.new(false, error, "Parameter was not found")
    end
  end
end
