class CreateInfrastructureVariable
  include AwsClientWrapper

  attr_accessor :infrastructure, :infrastructure_variable

  def initialize(infrastructure:, infrastructure_variable:)
    self.infrastructure = infrastructure
    self.infrastructure_variable = infrastructure_variable
  end

  def call
    PutAwsParameter.new(infrastructure: infrastructure)
      .call(path: name_with_path, key_id: key_id, value: infrastructure_variable.value)
  end

  private

  def name_with_path
    "/dalmatian-variables/infrastructures/#{infrastructure.identifier}/#{infrastructure_variable.environment_name}/#{infrastructure_variable.name}"
  end

  def key_id
    "alias/dalmatian"
  end
end
