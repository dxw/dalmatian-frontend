class DeleteEnvironmentVariable
  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(environment_variable:)
    full_name = "#{infrastructure.identifier}/#{environment_variable.full_aws_name}"

    result = DeleteAwsParameter.new(infrastructure: infrastructure).call(path: full_name)
    result
  end
end
