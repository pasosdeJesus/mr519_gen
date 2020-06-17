source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'cancancan'                   # Control de acceso

gem "cocoon", git: "https://github.com/vtamara/cocoon.git", 
  branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'devise'   , '>= 4.7.2' # Autenticación

gem 'devise-i18n'                , '>= 1.9.1'

gem 'paperclip'                   # Anexos

gem 'rails'                 , '>= 6.0.3.1'

gem 'rails-i18n'                 , '>= 6.0.0'

gem 'redcarpet' # Descripciones en heb412_gen

gem 'simple_form'   , '>= 5.0.2' # Formularios

gem 'twitter_cldr'               # Localiación e internacionalización

gem 'will_paginate'               # Pagina listados

gem 'webpacker', '>= 5.1.1'


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git'
  #path: '../sip'


group :development, :test do
  # Depurar
  #gem 'byebug'

  gem 'colorize'
end

