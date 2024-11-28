# frozen_string_literal: true

Mr519Gen::Engine.routes.draw do

  resources :campos, only: [], param: :index do
    member do
      delete '(:id)', to: "campos#destroy", as: "eliminar"
      post '/' => "campos#create", as: "crear"
    end
  end

  resources :opcionescs, only: [], param: :index do
    member do
      delete '(:id)', to: "opcionescs#destroy", as: "eliminar"
      post '/' => "opcionescs#create", as: "crear"
    end
  end

  resources :encuestaspersona, path_names: { new: "nueva", edit: "edita" }
  resources :encuestasusuario, path_names: { new: "nueva", edit: "edita" }
  resources :formularios, path_names: { new: "nuevo", edit: "edita" }
  get "/formularios/copia/:formulario_id" =>
  "formularios#copia",
    as: :copia_formulario

  resources :planesencuesta,
    path_names: { new: "nuevo", edit: "edita" }

  get "/encuestasusuario/resultados/:encuestausuario_id" =>
    "encuestasusuario#resultados",
    as: :resultadosencuestausuario

  get "/encuestasusuario/creartodousuario/:encuestausuario_id" =>
  "encuestasusuario#creartodousuario",
    as: :creartodousuario

  get "/encuestaexterna/:adurl" => "encuestaspersona#externa",
    as: :encuestaexterna
end
