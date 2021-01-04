# frozen_string_literal: true

class DatabasesController < ApplicationController
  include AwsClientWrapper

  def index
    @infrastructure = Infrastructure.find(infrastructure_id)

    @databases = @infrastructure.rds.map { |rds|
      OpenStruct.new(
        identifier: rds["identifier"],
        name: rds["db_name"],
        engine: rds["engine"],
        engine_version: rds["engine_version"],
        instance_class: rds["instance_class"]
      )
    }
  end

  private

  def infrastructure_id
    params[:infrastructure_id]
  end
end
