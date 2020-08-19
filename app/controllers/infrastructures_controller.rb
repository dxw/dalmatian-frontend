# frozen_string_literal: true

class InfrastructuresController < ApplicationController
  def index
    @infrastructures = FindDalmatianConfiguration.new.infrastructures
  end
end
