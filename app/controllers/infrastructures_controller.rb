# frozen_string_literal: true

class InfrastructuresController < ApplicationController
  def index
    @infrastructures = Infrastructure.all
  end

  def show
    @infrastructure = Infrastructure.find(params[:id])
    @environment_variables = FindEnvironmentVariables.new(infrastructure: @infrastructure).call
  end
end
