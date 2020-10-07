# frozen_string_literal: true

class DalmatianBuildsController < ApplicationController
  def index
    @core_infrastructure = OpenStruct.new(identifier: ENV["DALMATIAN_CI_PIPELINE"], account_id: ENV["DALMATIAN_AWS_ACCOUNT_ID"])
    pipeline_states = FindBuildPipelines.new(infrastructure: @core_infrastructure).call
    @pipelines = pipeline_states.map { |state| PipelinePresenter.new(state) }
  end
end
