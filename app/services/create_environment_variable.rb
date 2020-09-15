class CreateEnvironmentVariable
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(environment_variable:)
    name_with_path = "/#{infrastructure.identifier}/#{environment_variable.full_aws_name}"
    key_id = "alias/#{infrastructure.identifier}-#{environment_variable.service_name}-#{environment_variable.environment_name}-ssm"

    aws_ssm_client.put_parameter(
      name: name_with_path,
      value: environment_variable.value,
      type: "SecureString",
      key_id: key_id,
      overwrite: true
    )
  end
end
