# frozen_string_literal: true

class InfrastructuresController < ApplicationController
  def index
    @infrastructures = Infrastructure.all
  end
  end
end
