# encoding: UTF-8

require 'mr519_gen/concerns/models/formulario'

module Mr519Gen
  class Formulario < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Formulario
  end
end
