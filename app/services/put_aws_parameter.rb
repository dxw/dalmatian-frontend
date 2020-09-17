class PutAwsParameter
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
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
