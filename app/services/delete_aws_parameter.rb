class DeleteAwsParameter
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(path:)
    aws_ssm_client.delete_parameter(name: path)
    Result.new(true)
  rescue Aws::SSM::Errors::ParameterNotFound => error
    Result.new(false, error, "Parameter was not found")
  end
end
