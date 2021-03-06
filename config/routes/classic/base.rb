Rails.application.routes.draw do
  root to: 'base#index', only: [:show]
  get '/robots.txt', to: 'base#robots', defaults: { format: 'text' }

  resources :searchs, only: [], path: 'search' do
    collection do
      get :judges
      get :prosecutors
    end
  end

  get 'about', to: 'base#about', as: :about
end
