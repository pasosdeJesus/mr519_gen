# encoding: UTF-8

require 'mr519_gen/concerns/models/encuestausuario_valorcampo'

module Mr519Gen
  class EncuestausuarioValorcampo < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::EncuestausuarioValorcampo
  end
end
