class FindBuildPipelines
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call
    @pipeline_states = relevant_pipeline_names.inject([]) { |array, pipeline_name|
      array << client.get_pipeline_state(name: pipeline_name)
    }
  end

  private

  def client
    @client ||= CodePipeline.new(infrastructure: @infrastructure).call
  end

  def pipelines
    @pipelines ||= client.list_pipelines
  end

  def pipeline_names
    pipelines.pipelines.map(&:name)
  end

  def relevant_pipeline_names
    pipeline_names.select { |name| name.include?(infrastructure.identifier) }
  end
end
