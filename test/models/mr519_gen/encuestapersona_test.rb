# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class EncuestapersonaTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?

      pe = Mr519Gen::Planencuesta.create(PRUEBA_PLANENCUESTA.merge(
        formulario_id: f.id,
      ))

      assert_predicate pe, :valid?

      r = Mr519Gen::Respuestafor.create(PRUEBA_RESPUESTAFOR.merge(
        formulario_id: f.id,
      ))

      assert_predicate r, :valid?

      e = Mr519Gen::Encuestapersona.new(PRUEBA_ENCUESTAPERSONA)
      e.respuestafor = r
      e.planencuesta = pe
      p = Msip::Persona.create(PRUEBA_PERSONA)

      assert_predicate p, :valid?
      e.persona = p

      assert_predicate e, :valid?

      assert_equal "2018-12-19", e.fechaini.to_s
      e.fechaini = "2019-12-19"

      assert_equal "2019-12-19", e.fechaini.to_s

      assert_equal "2018-12-19", e.fechacambio.to_s
      e.fechacambio = "2019-12-19"

      assert_equal "2019-12-19", e.fechacambio.to_s

      assert_equal "", e.presenta("valorcampo")

      assert Mr519Gen::Encuestapersona.filtro_fechainiini("2010-01-01")
      assert Mr519Gen::Encuestapersona.filtro_fechainifin("2010-01-01")
      assert Mr519Gen::Encuestapersona.filtro_persona(1)

      assert e.formulario_id > 0
      e.formulario_id = 1

      assert_equal 1, e.formulario_id

      p.destroy
      r.destroy
      e.destroy
      f.destroy
    end

    test "no valido" do
      e = Mr519Gen::Encuestapersona.new(PRUEBA_ENCUESTAPERSONA)

      assert_not e.valid?
      e.destroy
    end
  end
end
