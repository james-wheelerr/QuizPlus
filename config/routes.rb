Rails.application.routes.draw do
  get 'quizs/new'
  get '/quizs/new/:questions', to: "quizs#new"
  
  get 'quizs/results'
  get 'quizs/results/:currentSettings', to: "quizs#results"
  
  get 'static_pages/home'
  get '/home', to: 'static_pages#home'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root 'static_pages#home'
end
