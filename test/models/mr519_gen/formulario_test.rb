require_relative '../../test_helper'

module Mr519Gen
  class FormularioTest < ActiveSupport::TestCase
    PRUEBA_FORMULARIO = {
      nombre:'n',
      nombreinterno:'n',
    }

    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do
      f = Mr519Gen::Formulario.create PRUEBA_FORMULARIO
      assert f.valid?
      f.destroy
    end

    test "no valido" do
      f = Mr519Gen::Formulario.new PRUEBA_FORMULARIO
      f.nombre = nil
      assert_not f.valid?
      f.destroy
    end

  end
end
