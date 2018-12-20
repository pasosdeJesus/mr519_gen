# encoding: UTF-8

require_relative './formulario_test'
require_relative './campo_test'
require_relative './valorcampo_test'
require_relative './encuestausuario_test'
require_relative '../../test_helper'

module Mr519Gen
  class EncuestausuarioValorcampoTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(
        ::Mr519Gen::FormularioTest::PRUEBA_FORMULARIO)
      assert f.valid?
      e = Mr519Gen::Encuestausuario.new(
        Mr519Gen::EncuestausuarioTest::PRUEBA_ENCUESTAUSUARIO)
      e.formulario = f
      u = ::Usuario.new(
        Mr519Gen::EncuestausuarioTest::PRUEBA_USUARIO)
      assert u.valid?
      e.usuario = u
      assert e.valid?
      c = Mr519Gen::Campo.new(Mr519Gen::CampoTest::PRUEBA_CAMPO)
      c.formulario = f
      assert c.valid?
      v = Mr519Gen::Valorcampo.new(
        Mr519Gen::ValorcampoTest::PRUEBA_VALORCAMPO)
      v.campo = c
      assert v.valid?
      
      ev = Mr519Gen::EncuestausuarioValorcampo.new
      ev.encuestausuario = e
      ev.valorcampo = v
      assert ev.valid?

      ev.destroy
      v.destroy
      c.destroy
      u.destroy
      e.destroy
      f.destroy
    end

    test "no valido" do
      ev = Mr519Gen::EncuestausuarioValorcampo.new
      assert_not ev.valid?
      ev.destroy
    end

  end
end
