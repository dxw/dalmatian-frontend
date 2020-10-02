# frozen_string_literal: true

class EnvironmentVariablesController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @environment_variable = EnvironmentVariable.new
  end

  def create
    @infrastructure = Infrastructure.find(params[:infrastructure_id])

    @environment_variable = EnvironmentVariable.new(environment_variable_params)

    if @environment_variable.valid?
      CreateEnvironmentVariable.new(
        infrastructure: @infrastructure,
        environment_variable: @environment_variable
      ).call
      flash_message = {}
      flash_message[:notice] = "This variable was successfully set"
      flash_message[:danger] = "To apply this change to the service you will need to execute a new deployment from the builds tab"
      redirect_to infrastructure_environment_variables_path(@infrastructure), flash: flash_message
    else
      render :new
    end
  end

  def destroy
    @infrastructure = Infrastructure.find(params[:infrastructure_id])

    environment_variable = EnvironmentVariable.new(environment_variable_params)
    result = DeleteEnvironmentVariable.new(infrastructure: @infrastructure).call(environment_variable: environment_variable)

    flash_message = result.success? ? {notice: "#{environment_variable.name} has been successfully deleted"} : {error: result.error_message}
    redirect_to infrastructure_environment_variables_path(@infrastructure), flash: flash_message
  end

  def index
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @environment_variables = FindEnvironmentVariables.new(infrastructure: @infrastructure).call
  end

  def service_name
    params["service_name"]
  end
  helper_method :service_name

  def environment_name
    params["environment_name"]
  end
  helper_method :environment_name

  private

  def environment_variable_params
    params.require("environment_variable").permit(:name, :value, :service_name, :environment_name)
  end
end
