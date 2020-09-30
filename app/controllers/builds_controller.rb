# frozen_string_literal: true

class BuildsController < ApplicationController
  def index
    @infrastructure = Infrastructure.find(infrastructure_id)
    @builds = FindBuilds.new(infrastructure: @infrastructure).call
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end
end
