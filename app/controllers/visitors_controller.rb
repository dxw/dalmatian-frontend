# frozen_string_literal: true

class VisitorsController < ApplicationController
  def index
    @infrastructures = FindDalmatianConfiguration.new.infrastructures
  end
end
