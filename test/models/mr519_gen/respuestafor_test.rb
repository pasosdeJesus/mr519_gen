# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class RespuestaforTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = ::Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?
      e = ::Mr519Gen::Respuestafor.new(PRUEBA_RESPUESTAFOR)
      e.formulario = f

      assert_predicate e, :valid?
      e.destroy
      f.destroy
    end

    test "no valido" do
      e = ::Mr519Gen::Respuestafor.new(PRUEBA_RESPUESTAFOR)

      assert_not e.valid?
      e.destroy
    end
  end
end
