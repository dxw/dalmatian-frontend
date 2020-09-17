# frozen_string_literal: true

class InfrastructureVariablesController < ApplicationController
  def index
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @infrastructure_variables = FindInfrastructureVariables.new(infrastructure: @infrastructure).call
  end
end
