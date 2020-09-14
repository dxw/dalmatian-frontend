# frozen_string_literal: true

class EnvironmentVariablesController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(params[:infrastructure_id])
    @environment_variable = EnvironmentVariable.new
  end

  def create
    @infrastructure = Infrastructure.find(params[:infrastructure_id])

    @environment_variable = EnvironmentVariable.new(environment_variable_params)

    if @environment_variable.valid? && safe_service_name? && safe_environment_name?
      CreateEnvironmentVariable.new(infrastructure: @infrastructure)
        .call(environment_variable: @environment_variable)
      redirect_to infrastructure_path(@infrastructure)
    else
      render :new
    end
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

  def name
    environment_variable_params[:name]
  end

  def value
    environment_variable_params[:value]
  end

  def safe_environment_name?
    raise ArgumentError unless @infrastructure.environment_names.include?(environment_variable_params[:environment_name])
    true
  end

  def safe_service_name?
    raise ArgumentError unless @infrastructure.service_names.include?(environment_variable_params[:service_name])
    true
  end
end
