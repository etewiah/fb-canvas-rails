FBCanvasRails::Application.routes.draw do
  match '/facebook/channel', to: 'facebook#channel'
  match '/auth/:provider/callback', to: 'session#create'
  match '/auth/failure', to: 'session#destroy'

  match '/', to: 'home#index'
  match '/page1', to: 'home#page1'
  match '/page2', to: 'home#page2'
  match '/page3', to: 'home#page3'
end
