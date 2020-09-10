Mr519Gen::Engine.routes.draw do

  resources :campos, only: [:new, :destroy]
  resources :encuestaspersona, path_names: { new: 'nueva', edit: 'edita' }
  resources :encuestasusuario, path_names: { new: 'nueva', edit: 'edita' }
  resources :formularios, path_names: { new: 'nuevo', edit: 'edita' }
  resources :opcionescs, only: [:new, :destroy]

  get '/encuestasusuario/resultados/:encuestausuario_id' => 
    "encuestasusuario#resultados",
    as: :resultadosencuestausuario

    get '/encuestasusuario/creartodousuario/:encuestausuario_id' => 
    "encuestasusuario#creartodousuario",
    as: :creartodousuario


  get '/encuestaexterna/:adurl' => 'encuestaspersona#externa', 
    as: :encuestaexterna
end
