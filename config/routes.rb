Mr519Gen::Engine.routes.draw do

  resources :campos, only: [:new, :destroy]
  resources :encuestaspersona, path_names: { new: 'nueva', edit: 'edita' }
  resources :encuestasusuario, path_names: { new: 'nueva', edit: 'edita' }
  resources :formularios, path_names: { new: 'nuevo', edit: 'edita' }
  resources :opcionescs, only: [:new, :destroy]

  get '/encuestasusuario/resultados/:formulario_id' => 
    "encuestasusuario#resultados",
    as: :resultadosencuesta

  get '/encuestaexterna/:adurl' => 'encuestaspersona#externa', 
    as: :encuestaexterna
end
