source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'cancancan'                   # Control de acceso

gem "cocoon", git: "https://github.com/vtamara/cocoon.git",
  branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'devise'   # Autenticación

gem 'devise-i18n'

gem 'nokogiri', '>=1.11.1'

gem 'paperclip'                   # Anexos

gem 'rails', '~> 6.0.3.4'

gem 'rails-i18n'

gem 'redcarpet' # Descripciones en heb412_gen

gem 'simple_form'   # Formularios

gem 'twitter_cldr'               # Localiación e internacionalización

gem 'will_paginate'               # Pagina listados

gem 'webpacker'


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

group :test do
  gem 'simplecov', '~>0.10', '<0.18'
end
