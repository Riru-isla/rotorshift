Rails.application.routes.draw do
  devise_for :users,
             path: "api/v1/auth",
             path_names: { sign_in: "sign_in", sign_out: "sign_out", registration: "sign_up" },
             controllers: {
               sessions: "api/v1/auth/sessions",
               registrations: "api/v1/auth/registrations"
             }

  namespace :api do
    namespace :v1 do
      get "me", to: "me#show"

      resources :organizations, only: [:index, :show, :create, :update]

      resources :shift_patterns, only: [:index, :show, :create, :update, :destroy]
      resources :pilot_profiles, only: [:index, :show, :create, :update]
      resources :holidays, only: [:index, :show, :create, :update, :destroy]
      resources :training_events, only: [:index, :show, :create, :update, :destroy]
      resources :staffing_requirements, only: [:index, :show, :create, :update, :destroy]

      resources :unavailable_days, only: [:index, :create, :destroy]
      resources :vacation_requests, only: [:index, :show, :create, :update] do
        member do
          patch :approve
          patch :deny
        end
      end

      resources :schedules, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch :publish
          patch :unpublish
        end
        resources :schedule_entries, only: [:index, :create, :update, :destroy]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
