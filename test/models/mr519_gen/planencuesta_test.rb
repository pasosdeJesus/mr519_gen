# frozen_string_literal: true

require_relative "../../test_helper"

module Mr519Gen
  class PlanencuestaTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?
      p = Mr519Gen::Planencuesta.create(PRUEBA_PLANENCUESTA.merge(
        formulario_id: f.id,
      ))

      assert_predicate p, :valid?
      p.destroy
      f.destroy
    end

    test "no valido" do
      p = Mr519Gen::Planencuesta.create(PRUEBA_PLANENCUESTA.merge(
        formulario_id: nil,
      ))

      assert_not p.valid?
      p.destroy
    end
  end
end
