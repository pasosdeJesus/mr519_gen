# frozen_string_literal: true

require_relative "formulario_test"
require_relative "../../test_helper"

module Mr519Gen
  class OpcioncsTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?
      c = Mr519Gen::Campo.create(PRUEBA_CAMPO.merge(formulario_id: f.id))

      assert_predicate c, :valid?
      o = Mr519Gen::Opcioncs.create(PRUEBA_OPCIONCS.merge(campo_id: c.id))

      assert_predicate o, :valid?

      o.destroy
      c.destroy
      f.destroy
    end

    test "no valido" do
      c = Mr519Gen::Opcioncs.new(PRUEBA_OPCIONCS)

      assert_not c.valid?
      c.destroy
    end
  end
end
