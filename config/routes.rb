Mr519Gen::Engine.routes.draw do

  resources :campos, only: [:new, :destroy]
  resources :encuestasusuario, path_names: { new: 'nueva', edit: 'edita' }
  resources :formularios, path_names: { new: 'nuevo', edit: 'edita' }

  get '/encuestasusuario/resultados/:formulario_id' => 
    "encuestasusuario#resultados",
    as: :resultadosencuesta
end
