require 'sip/concerns/models/usuario'


module Mr519Gen
  module Concerns
    module Models
      module Usuario
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Usuario

          has_many :encuestausuario, 
            class_name: 'Mr519Gen::Encuestausuario',
            foreign_key: 'usuario_id',
            dependent: :delete_all

        end

      end
    end
  end
end

