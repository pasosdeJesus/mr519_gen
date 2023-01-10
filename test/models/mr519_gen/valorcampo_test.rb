# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class ValorcampoTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate f, :valid?
      c = Mr519Gen::Campo.new(PRUEBA_CAMPO)
      c.formulario = f

      assert_predicate c, :valid?
      c.save
      r = Mr519Gen::Respuestafor.new(PRUEBA_RESPUESTAFOR)
      r.formulario = f
      r.save

      assert_predicate r, :valid?

      v = Mr519Gen::Valorcampo.new(PRUEBA_VALORCAMPO)
      v.campo = c
      v.respuestafor = r

      assert_predicate v, :valid?
      assert_equal "c: 1", v.presenta_valor
      assert_equal "1", v.presenta_valor(false)

      v.campo.tipo = Mr519Gen::ApplicationHelper::ENTERO

      assert_equal 1, v.presenta_valor(false)
      assert_equal "c: 1", v.presenta_valor(true)
      v.campo.tipo = Mr519Gen::ApplicationHelper::FLOTANTE

      assert_in_delta(1.0, v.presenta_valor(false))
      assert_equal "c: 1.0", v.presenta_valor(true)
      v.campo.tipo = Mr519Gen::ApplicationHelper::PRESENTATEXTO

      assert_equal "c", v.presenta_valor(false)
      v.campo.tipo = Mr519Gen::ApplicationHelper::BOOLEANO

      assert_equal "SI", v.presenta_valor(false)
      o = Mr519Gen::Opcioncs.new(id: 1, campo_id: 1, nombre: "x", valor: "x")
      o.save
      v.campo.tipo = Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
      v.valor_ids = [1, 2]

      assert_equal "[1, 2]", v.valor_ids.to_s
      assert_equal "[1, 2]", v.presenta_valor(false).to_s
      v.campo.tipo = Mr519Gen::ApplicationHelper::SELECCIONSIMPLE
      o = Mr519Gen::Opcioncs.new(
        id: 1, campo_id: c.id, nombre: "x", valor: "x",
      )
      o.save

      assert_equal "x", v.presenta_valor(false)
      v.campo.tipo = Mr519Gen::ApplicationHelper::SMTABLABASICA

      assert_equal "Problema tablabasica es nil", v.presenta_valor(false)
      v.campo.tablabasica = "Pais"

      assert_equal "Problema con tablabasica Pais  porque hay 0", v.presenta_valor(false)
      v.campo.tablabasica = "pais"
      v.valor_ids = [170, 686]

      assert_equal "Colombia; Senegal", v.presenta_valor(false)
      v.campo.tipo = Mr519Gen::ApplicationHelper::SSTABLABASICA
      v.campo.tablabasica = nil

      assert_equal "Problema tablabasica es nil", v.presenta_valor(false)
      v.campo.tablabasica = "Pais"

      assert_equal "Problema con tablabasica Pais  porque hay 0", v.presenta_valor(false)
      v.campo.tablabasica = "pais"
      v.valor = 686

      assert_equal "Senegal", v.presenta_valor(false)

      v.destroy
      r.destroy
      c.destroy
      f.destroy
    end

    test "no valido" do
      c = Mr519Gen::Valorcampo.new(PRUEBA_VALORCAMPO)

      assert_not c.valid?
      c.destroy
    end
  end
end
