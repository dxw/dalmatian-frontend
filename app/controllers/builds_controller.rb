# frozen_string_literal: true

class BuildsController < ApplicationController
  include AwsClientWrapper
  def index
    @infrastructure = Infrastructure.find(infrastructure_id)
    @pipeline_states = FindBuildPipelines.new(infrastructure: @infrastructure).call
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end
end
