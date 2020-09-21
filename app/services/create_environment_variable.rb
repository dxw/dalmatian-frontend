class CreateEnvironmentVariable
  include AwsClientWrapper

  attr_accessor :infrastructure, :environment_variable

  def initialize(infrastructure:, environment_variable:)
    self.infrastructure = infrastructure
    self.environment_variable = environment_variable
  end

  def call
    PutAwsParameter.new(infrastructure: infrastructure)
      .call(path: name_with_path, key_id: key_id, value: environment_variable.value)
  end

  private

  def name_with_path
    "/#{infrastructure.identifier}/#{environment_variable.full_aws_name}"
  end

  def key_id
    "alias/#{infrastructure.identifier}-#{environment_variable.service_name}-#{environment_variable.environment_name}-ssm"
  end
end
