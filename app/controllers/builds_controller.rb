# frozen_string_literal: true

class BuildsController < ApplicationController
  include AwsClientWrapper

  def index
    @infrastructure = Infrastructure.find(infrastructure_id)
    pipeline_states = FindBuildPipelines.new(infrastructure: @infrastructure).call
    @pipelines = pipeline_states.map { |state| PipelinePresenter.new(state) }
  end

  def new
    @infrastructure = Infrastructure.find(infrastructure_id)

    result = ExecuteCodePipeline.new(infrastructure: @infrastructure)
      .call(pipeline_name: pipeline_name)

    flash_message = {}
    flash_message[:notice] = "CodePipeline '#{pipeline_name}' has been executed" if result.success?
    flash_message[:error] = "CodePipeline '#{pipeline_name}' failed because #{result.error_message}" if result.failure?

    redirect_to infrastructure_builds_path(@infrastructure), flash: flash_message
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end

  def pipeline_name
    params[:pipeline]
  end
end
