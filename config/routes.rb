# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "infrastructures#index"

  resources :dalmatian_builds, only: [:index, :new]
  resources :infrastructures, only: [:show, :index] do
    resources :environment_variables, only: [:new, :create, :destroy, :index] do
      collection do
        resources :downloads, only: [:new]
        resources :env_files, only: [:new, :create] do
          collection do
            post "confirm", to: "env_files#confirm"
          end
        end
      end
    end
    resources :infrastructure_variables, only: [:new, :create, :destroy, :index], as: :variables
    resources :builds, only: [:index, :new]
  end
end
