class DeleteAwsParameter
  attr_accessor :aws_ssm_client, :infrastructure

  def initialize(aws_ssm_client:, infrastructure:)
    self.aws_ssm_client = aws_ssm_client
    self.infrastructure = infrastructure
  end

  def call(path:)
    aws_ssm_client.delete_parameter(name: path)
    Result.new(true)
  rescue Aws::SSM::Errors::ParameterNotFound => error
    Result.new(false, error, "Parameter was not found")
  end
end
