Rails.application.routes.draw do

  root 'welcome#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  #devise_for :users

end
