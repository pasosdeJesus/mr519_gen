# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "bootsnap"

gem "cancancan" # Control de acceso

gem "devise" # Autenticación

gem "devise-i18n"

gem "kt-paperclip", # Anexos
  git: "https://github.com/kreeti/kt-paperclip.git"

gem "nokogiri", ">=1.11.1"

gem "pg"

gem "rails-i18n"

gem "rails", "~> 8.0"
# git: 'https://github.com/rails/rails.git', branch: '6-1-stable'

gem "redcarpet" # Descripciones en heb412_gen

gem "simple_form" # Formularios

gem "sprockets-rails"

gem "stimulus-rails"

gem "turbo-rails"

gem "twitter_cldr" # Localiación e internacionalización

gem "will_paginate" # Pagina listados

#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento
# lógico y no alfabetico como las gemas anteriores)

gem "msip", # Motor generico
  git: "https://gitlab.com/pasosdeJesus/msip.git", branch: "main"
  #path: "../msip"

group :development do
  gem "puma"

  gem "spring"

  gem "web-console"
end

group :development, :test do
  gem "brakeman"

  gem "bundler-audit"

  gem "code-scanning-rubocop"

  gem "colorize"

  gem "debug"

  gem "dotenv-rails"

  gem "rails-erd"

  gem "rubocop-erb" #, "< 0.7.0"

  gem "rubocop-minitest"

  gem "rubocop-rails"

  gem "rubocop-shopify"
end

group :test do
  gem "rails-controller-testing"

  gem "simplecov"
end
