require_relative './formulario_test'
require_relative '../../test_helper'

module Mr519Gen
  class CampoTest < ActiveSupport::TestCase
    PRUEBA_CAMPO = {
      nombre: 'c',
      nombreinterno: 'c',
    }

    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do
      f = Mr519Gen::Formulario.create Mr519Gen::FormularioTest::PRUEBA_FORMULARIO 
      assert f.valid?
      c = Mr519Gen::Campo.new PRUEBA_CAMPO
      c.formulario = f
      assert c.valid?
      c.destroy
      f.destroy
    end

    test "no valido" do
      c = Mr519Gen::Campo.new PRUEBA_CAMPO
      assert_not c.valid?
      c.destroy
    end

  end
end
