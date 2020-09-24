class PutAwsParameter
  attr_accessor :aws_ssm_client, :infrastructure

  def initialize(aws_ssm_client:, infrastructure:)
    self.aws_ssm_client = aws_ssm_client
    self.infrastructure = infrastructure
  end

  def call(path:, key_id:, value:)
    aws_ssm_client.put_parameter(
      name: path,
      value: value,
      type: "SecureString",
      key_id: key_id,
      overwrite: true
    )
  end
end
