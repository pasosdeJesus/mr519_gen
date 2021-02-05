Rails.application.routes.draw do

  rutarel = ENV.fetch('RUTA_RELATIVA', 'mr519/')
  scope rutarel do 
    devise_scope :usuario do
      get 'sign_out' => 'devise/sessions#destroy'
    end
    devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
      get 'usuarios/edit' => 'devise/registrations#edit', 
        :as => 'editar_registro_usuario'    
      put 'usuarios/:id' => 'devise/registrations#update', 
        :as => 'registro_usuario'            
    end
    resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' }  
  
    root 'sip/hogar#index'
  end
  mount Sip::Engine, at: rutarel, as: 'sip'
  mount Mr519Gen::Engine, at: rutarel, as: 'mr519_gen'
end
