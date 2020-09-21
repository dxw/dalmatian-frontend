class DeleteInfrastructureVariable
  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(infrastructure_variable:)
    full_name = "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{infrastructure_variable.environment_name}/#{infrastructure_variable.name}"

    result = DeleteAwsParameter.new(infrastructure: infrastructure).call(path: full_name)
    result
  end
end
