source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem 'babel-transpiler'

gem "bigdecimal"

gem 'cancancan'                   # Control de acceso

gem "cocoon", git: "https://github.com/vtamara/cocoon.git",
  branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails'

gem "concurrent-ruby", "1.3.4" #https://stackoverflow.com/questions/79360526/uninitialized-constant-activesupportloggerthreadsafelevellogger-nameerror

gem 'devise'   # Autenticación

gem 'devise-i18n'

gem "drb"

gem 'jsbundling-rails'

gem 'kt-paperclip',                 # Anexos
  git: 'https://github.com/kreeti/kt-paperclip.git'

gem "mutex_m"

gem 'nokogiri', '>=1.11.1'

gem 'rails', '~> 7', '< 7.1'
  #git: 'https://github.com/rails/rails.git', branch: '6-1-stable'

gem 'rails-i18n'

gem 'redcarpet' # Descripciones en heb412_gen

gem 'sassc-rails'

gem 'simple_form'   # Formularios

gem 'sprockets-rails'

gem 'stimulus-rails'

gem 'turbo-rails', '~> 1.0'

gem 'twitter_cldr'               # Localiación e internacionalización

gem 'will_paginate'               # Pagina listados


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento
# lógico y no alfabetico como las gemas anteriores)

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git', branch: 'v2.1'
  #path: '../sip'


group :development do
  gem 'puma'

  gem 'spring'

  gem 'web-console'
end

group :development, :test do
  # Depurar
  gem 'debug'

  gem 'colorize'

  gem 'dotenv-rails'
end

group :test do
  gem 'cuprite'

  gem 'simplecov', '~>0.10', '<0.18'
end
