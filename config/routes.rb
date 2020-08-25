# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "infrastructures#index"

  resources :infrastructures, only: [:show, :index]
end
