# frozen_string_literal: true

require "mr519_gen/concerns/models/valorcampo"

module Mr519Gen
  # Valor que un usuario/persona diligencia en un campo de un formulario
  class Valorcampo < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Valorcampo
  end
end
