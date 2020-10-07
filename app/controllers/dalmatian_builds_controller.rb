# frozen_string_literal: true

class DalmatianBuildsController < ApplicationController
  def index
    @core_infrastructure = OpenStruct.new(identifier: ENV["DALMATIAN_CI_PIPELINE"], account_id: ENV["DALMATIAN_AWS_ACCOUNT_ID"])
    pipeline_states = FindBuildPipelines.new(infrastructure: @core_infrastructure).call
    @pipelines = pipeline_states.map { |state| PipelinePresenter.new(state) }
  end

  def new
    @core_infrastructure = OpenStruct.new(identifier: ENV["DALMATIAN_CI_PIPELINE"], account_id: ENV["DALMATIAN_AWS_ACCOUNT_ID"])

    result = ExecuteCodePipeline.new(infrastructure: @core_infrastructure)
      .call(pipeline_name: pipeline_name)

    flash_message = {}
    flash_message[:notice] = "CodePipeline '#{pipeline_name}' has been executed" if result.success?
    flash_message[:error] = "CodePipeline '#{pipeline_name}' failed because #{result.error_message}" if result.failure?

    redirect_to dalmatian_builds_path, flash: flash_message
  end

  private

  def pipeline_name
    params[:pipeline]
  end
end
