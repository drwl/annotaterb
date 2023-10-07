# frozen_string_literal: true

# == Route Map
#
#                 Prefix Verb   URI Pattern                       Controller#Action
#                   root GET    /                                 articles#index
#              resources GET    /resources(.:format)              resources#index
#                        POST   /resources(.:format)              resources#create
#           new_resource GET    /resources/new(.:format)          resources#new
#          edit_resource GET    /resources/:id/edit(.:format)     resources#edit
#               resource GET    /resources/:id(.:format)          resources#show
#                        PATCH  /resources/:id(.:format)          resources#update
#                        PUT    /resources/:id(.:format)          resources#update
#                        DELETE /resources/:id(.:format)          resources#destroy
#  new_singular_resource GET    /singular_resource/new(.:format)  singular_resources#new
# edit_singular_resource GET    /singular_resource/edit(.:format) singular_resources#edit
#      singular_resource GET    /singular_resource(.:format)      singular_resources#show
#                        PATCH  /singular_resource(.:format)      singular_resources#update
#                        PUT    /singular_resource(.:format)      singular_resources#update
#                        DELETE /singular_resource(.:format)      singular_resources#destroy
#                        POST   /singular_resource(.:format)      singular_resources#create
#                 manual GET    /manual(.:format)                 manual#show

Rails.application.routes.draw do
  root "articles#index"
  resources :resources
  resource :singular_resource

  get "/manual", to: "manual#show"
end
