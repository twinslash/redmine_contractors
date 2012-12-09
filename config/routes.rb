# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :people do
    collection do
      get :bulk_edit, :context_menu, :edit_mails, :preview_email, :avatar
      post :bulk_edit, :bulk_update, :send_mails
      delete :bulk_destroy
    end
end

resources :people_settings do
  collection do
    get :autocomplete_for_user
  end
end
# match "people_settings/:action" => "people_settings"

