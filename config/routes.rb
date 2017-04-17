Rails::AddOns::Engine.routes.draw do
  resource :widget, only: [:show] do
    post ':name' => :remote_render, on: :collection, as: :render
  end
end
