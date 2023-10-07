# frozen_string_literal: true

Rails.application.routes.draw do
  root "articles#index"
  resources :resources
  resource :singular_resource

  get "/manual", to: "manual#show"
end
