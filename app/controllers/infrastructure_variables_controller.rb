# frozen_string_literal: true

class InfrastructureVariablesController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @infrastructure_variable = InfrastructureVariable.new
  end

  def create
    @infrastructure = Infrastructure.find(params[:infrastructure_id])

    @infrastructure_variable = InfrastructureVariable.new(infrastructure_variable_params)

    if @infrastructure_variable.valid?
      CreateInfrastructureVariable.new(
        infrastructure: @infrastructure,
        infrastructure_variable: @infrastructure_variable
      ).call
      redirect_to infrastructure_variables_path(@infrastructure)
    else
      render :new
    end
  end

  def destroy
    @infrastructure = Infrastructure.find(params[:infrastructure_id])

    infrastructure_variable = InfrastructureVariable.new(infrastructure_variable_params)
    result = DeleteInfrastructureVariable.new(infrastructure: @infrastructure).call(infrastructure_variable: infrastructure_variable)

    flash_message = result.success? ? {notice: "#{infrastructure_variable.name} has been successfully deleted"} : {error: result.error_message}
    redirect_to infrastructure_variables_path(@infrastructure), flash: flash_message
  end

  def index
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @infrastructure_variables = FindInfrastructureVariables.new(infrastructure: @infrastructure).call
  end

  def environment_name
    params["environment_name"]
  end
  helper_method :environment_name

  private

  def infrastructure_variable_params
    params.require("infrastructure_variable").permit(:name, :value, :environment_name)
  end
end
