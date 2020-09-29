# frozen_string_literal: true

class DownloadsController < ApplicationController
  def new
    @infrastructure = Infrastructure.find(infrastructure_id)
    all_environment_variables = FindEnvironmentVariables.new(infrastructure: @infrastructure).call
    environment_variables = all_environment_variables[service_name][environment_name]

    filename = "dalmatian_#{service_name}_#{environment_name}_#{Time.now.utc.to_i}.env"
    file_path = "./tmp/#{filename}"
    File.atomic_write(file_path) do |file|
      environment_variables.each do |variable|
        file.write("#{variable.name}=#{variable.value}\n")
      end
    end

    send_file(
      file_path,
      filename: filename,
      type: "application/env"
    )
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end

  def service_name
    params["service_name"]
  end

  def environment_name
    params["environment_name"]
  end
end
