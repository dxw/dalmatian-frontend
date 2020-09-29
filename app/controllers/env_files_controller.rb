# frozen_string_literal: true

class EnvFilesController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(infrastructure_id)
    @env_file = EnvFile.new
  end

  def confirm
    @infrastructure = Infrastructure.find(infrastructure_id)

    if EnvFile.valid?(tempfile: env_file_params[:tempfile])
      EnvFile.persist(tempfile: env_file_params[:tempfile])
      @env_file = EnvFile.new(file_name: env_file_params[:tempfile].original_filename)
    else
      redirect_to new_infrastructure_env_file_path(
        @infrastructure, service_name: service_name, environment_name: environment_name
      ), flash: {error: "Invalid file"}
    end
  end

  def create
    @infrastructure = Infrastructure.find(infrastructure_id)
    @env_file = EnvFile.new(file_name: env_file_params[:file_name])

    results = CreateMultipleEnvironmentVariables.new(
      infrastructure: @infrastructure,
      env_file: @env_file,
      service_name: service_name,
      environment_name: environment_name
    ).call

    successful_results, failed_results = results.partition { |result| result.success? }
    flash_message = {}
    flash_message[:notice] = "#{successful_results.count} #{"change".pluralize(successful_results.count)} succeeded" unless successful_results.empty?
    flash_message[:error] = "#{failed_results.count} #{"change".pluralize(successful_results.count)} failed with: " + failed_results.map(&:error_message).join(", ") unless failed_results.empty?

    redirect_to infrastructure_environment_variables_path(@infrastructure), flash: flash_message
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

  def infrastructure_id
    params[:infrastructure_id]
  end

  def env_file_params
    params.require(:env_file).permit(:tempfile, :file_name)
  end
end
