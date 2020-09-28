# frozen_string_literal: true

class EnvFilesController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(infrastructure_id)
    @env_file = EnvFile.new
  end

  def confirm
    @infrastructure = Infrastructure.find(infrastructure_id)

    file_name = env_file_params[:tempfile].original_filename
    EnvFile.persist(tempfile: env_file_params[:tempfile])

    @env_file = EnvFile.new(file_name: file_name)
  end

  def create
    @infrastructure = Infrastructure.find(infrastructure_id)
    @env_file = EnvFile.new(file_name: env_file_params[:file_name])

    @env_file.contents.each_pair do |key, value|
      environment_variable = EnvironmentVariable.new(
        name: key,
        value: value,
        service_name: service_name,
        environment_name: environment_name
      )
      CreateEnvironmentVariable.new(
        infrastructure: @infrastructure,
        environment_variable: environment_variable
      ).call
    end

    redirect_to infrastructure_environment_variables_path(@infrastructure)
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
