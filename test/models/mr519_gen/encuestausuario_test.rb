require_relative './formulario_test'
require_relative './respuestafor_test'
require_relative '../../test_helper'

module Mr519Gen
  class EncuestausuarioTest < ActiveSupport::TestCase
    PRUEBA_ENCUESTAUSUARIO = {
      usuario_id: 1,
      fechainicio: '2018-12-01',
      fechafin: '2018-12-31',
    }

    PRUEBA_USUARIO= {
      nusuario: "mr519gen",
      password: "mr519gen",
      nombre: "admin",
      descripcion: "admin",
      rol: 1,
      idioma: "es_CO",
      email: "usuario1@localhost",
      encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
      sign_in_count: 0,
      fechacreacion: "2018-12-19",
      fechadeshabilitacion: nil,
    }


    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)
      assert f.valid?

      r = Mr519Gen::Respuestafor.new(PRUEBA_RESPUESTAFOR)
      r.formulario = f
      r.save
      assert r.valid?

      e = Mr519Gen::Encuestausuario.new(PRUEBA_ENCUESTAUSUARIO)
      e.respuestafor = r
      u = ::Usuario.new(PRUEBA_USUARIO)
      assert u.valid?
      e.usuario = u
      assert e.valid?

      assert_equal '2018-12-19', e.fechaini_localizada
      e.fechaini_localizada = '2019-12-19'
      assert_equal '2019-12-19', e.fechaini_localizada

      assert_equal '2018-12-19', e.fechacambio_localizada
      e.fechacambio_localizada = '2019-12-19'
      assert_equal '2019-12-19', e.fechacambio_localizada

      assert_equal '', e.presenta('valorcampo')

      assert Mr519Gen::Encuestausuario.filtro_fechainiini '2010-01-01'
      assert Mr519Gen::Encuestausuario.filtro_fechainifin '2010-01-01'
      assert Mr519Gen::Encuestausuario.filtro_usuario 1
      assert Mr519Gen::Encuestausuario.filtro_formulario 22

      assert e.formulario_id > 0
      e.formulario_id = 1
      assert_equal 1, e.formulario_id

      u.destroy
      r.destroy
      e.destroy
      f.destroy
    end

    test "no valido" do
      e = Mr519Gen::Encuestausuario.new PRUEBA_ENCUESTAUSUARIO
      assert_not e.valid?
      e.destroy
    end

  end
end
