# encoding: UTF-8

require_relative './formulario_test'
require_relative './campo_test'
require_relative '../../test_helper'

module Mr519Gen
  class ValorcampoTest < ActiveSupport::TestCase
    PRUEBA_VALORCAMPO = {
      valor: 1
    }

    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(
        Mr519Gen::FormularioTest::PRUEBA_FORMULARIO)
      assert f.valid?
      c = Mr519Gen::Campo.new(Mr519Gen::CampoTest::PRUEBA_CAMPO)
      c.formulario = f
      assert c.valid?
      v = Mr519Gen::Valorcampo.new(PRUEBA_VALORCAMPO)
      v.campo = c
      assert v.valid?
      v.destroy
      c.destroy
      f.destroy
    end

    test "no valido" do
      c = Mr519Gen::Valorcampo.new PRUEBA_VALORCAMPO
      assert_not c.valid?
      c.destroy
    end

  end
end
