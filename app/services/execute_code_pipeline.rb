class ExecuteCodePipeline
  include AwsClientWrapper

  attr_accessor :infrastructure

  def initialize(infrastructure:)
    self.infrastructure = infrastructure
  end

  def call(pipeline_name:)
    begin
      client.start_pipeline_execution(name: pipeline_name)
      result = Result.new(true)
    rescue Aws::CodePipeline::Errors::PipelineNotFoundException => error
      result = Result.new(false, error, error.message)
    end
    result
  end

  private

  def client
    @client ||= CodePipeline.new(infrastructure: @infrastructure).call
  end
end
