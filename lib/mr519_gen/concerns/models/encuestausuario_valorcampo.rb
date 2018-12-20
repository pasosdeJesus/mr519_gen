# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Models
      module EncuestausuarioValorcampo
        extend ActiveSupport::Concern

        included do

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_encuestausuario_valorcampo'

          belongs_to :encuestausuario, 
            class_name: 'Mr519Gen::Encuestausuario', 
            foreign_key: 'encuestausuario_id', 
            validate: true
          belongs_to :valorcampo, 
            class_name: 'Mr519Gen::Valorcampo', 
            foreign_key: 'valorcampo_id', 
            validate: true

        end # included
      end
    end
  end
end

