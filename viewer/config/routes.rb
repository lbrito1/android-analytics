Rails.application.routes.draw do
  root to: redirect('/blazer')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Blazer::Engine, at: "blazer"
end
