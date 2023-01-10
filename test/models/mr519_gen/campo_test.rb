# frozen_string_literal: true

require_relative "./formulario_test"
require_relative "../../test_helper"

module Mr519Gen
  class CampoTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?
      c = Mr519Gen::Campo.new(PRUEBA_CAMPO)
      c.formulario = f

      assert_predicate c, :valid?
      c.destroy
      f.destroy
    end

    test "no valido" do
      c = Mr519Gen::Campo.new(PRUEBA_CAMPO)

      assert_not c.valid?
      c.destroy
    end
  end
end
