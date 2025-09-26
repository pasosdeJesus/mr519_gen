# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class FormulariosControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    # include Cocoon::ViewHelpers

    setup do
      raise "CONFIG_HOSTS debe ser www.example.com" if ENV["CONFIG_HOSTS"] != "www.example.com"

      @current_usuario = ::Usuario.find(1)
      sign_in @current_usuario
      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)

      assert_predicate @formulario, :valid?
    end

    # Cada prueba que se ejecuta se hace en una transacción
    # que después de la prueba se revierte

    test "debe presentar listado" do
      get mr519_gen.formularios_path

      assert_response :success
      assert_template :index
    end

    test "debe presentar resumen de existente" do
      get mr519_gen.formulario_url(@formulario.id)

      assert_response :success
      assert_template :show
    end

    test "debe presentar formulario para nueva" do
      get mr519_gen.new_formulario_path

      assert_response :redirect
    end

    test "debe presentar formulario de edición" do
      get mr519_gen.edit_formulario_path(@formulario)

      assert_response :success
      assert_template :edit
    end

    test "debe crear nueva" do
      # Arreglamos indice
      # Msip::Formulario.connection.execute(<<-SQL.squish)
      #  SELECT setval('public.mr519_gen.formulario_id_seq', MAX(id))#{" "}
      #    FROM public.mr519_gen.formulario;
      # SQL
      assert_difference("Formulario.count") do
        post mr519_gen.formularios_path, params: {
          formulario: {
            id: nil,
            nombre: "z",
            nombreinterno: "z",
          },
        }
      end

      assert_redirected_to mr519_gen.formulario_path(
        assigns(:formulario),
      )
    end

    test "debe actualizar existente" do
      patch mr519_gen.formulario_path(@formulario.id),
        params: {
          formulario: {
            id: @formulario.id,
            nombre: "u",
            nombreinterno: "u",
          },
        }

      assert_redirected_to mr519_gen.formulario_path(assigns(:formulario))
    end

    test "debe eliminar" do
      assert_difference("Formulario.count", -1) do
        delete mr519_gen.formulario_path(Formulario.find(@formulario.id))
      end

      assert_redirected_to mr519_gen.formularios_path
    end
  end
end
