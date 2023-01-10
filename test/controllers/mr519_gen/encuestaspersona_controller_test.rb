# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class EncuestaspersonaControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers
    # include Cocoon::ViewHelpers

    setup do
      raise "CONFIG_HOSTS debe ser www.example.com" if ENV["CONFIG_HOSTS"] != "www.example.com"

      @current_usuario = ::Usuario.find(1)
      sign_in @current_usuario
      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)

      assert_predicate @formulario, :valid?
      @planencuesta = Mr519Gen::Planencuesta.create!(
        PRUEBA_PLANENCUESTA.merge(formulario_id: @formulario.id),
      )

      assert_predicate @planencuesta, :valid?
      @respuestafor = Mr519Gen::Respuestafor.create!(
        PRUEBA_RESPUESTAFOR.merge(formulario_id: @formulario.id),
      )

      assert_predicate @respuestafor, :valid?
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)

      assert_predicate @persona, :valid?
      @encuestapersona = Mr519Gen::Encuestapersona.create!(
        PRUEBA_ENCUESTAPERSONA.merge(
          planencuesta_id: @planencuesta.id,
          respuestafor_id: @respuestafor.id,
          persona_id: @persona.id,
        ),
      )

      assert_predicate @encuestapersona, :valid?
    end

    # Cada prueba que se ejecuta se hace en una transacción
    # que después de la prueba se revierte

    test "debe presentar listado" do
      get mr519_gen.encuestaspersona_path

      assert_response :success
      assert_template :index
    end

    test "debe presentar resumen de existente" do
      get mr519_gen.encuestapersona_url(@encuestapersona.id)

      assert_response :success
      assert_template :show
    end

    test "debe presentar formulario para nueva" do
      get mr519_gen.new_encuestapersona_path

      assert_response :redirect
    end

    test "debe presentar formulario de edición" do
      get mr519_gen.edit_encuestapersona_path(@encuestapersona)

      assert_response :success
      assert_template :edit
    end

    test "debe crear nueva" do
      skip # No se hace create porque new, crea y redirige a edición
      # Arreglamos indice
      # Msip::Encuestapersona.connection.execute(<<-SQL.squish)
      #  SELECT setval('public.mr519_gen.encuestapersona_id_seq', MAX(id))#{" "}
      #    FROM public.mr519_gen.encuestapersona;
      # SQL
      assert_difference("Encuestapersona.count") do
        post mr519_gen.encuestaspersona_path, params: {
          encuestapersona: {
            id: nil,
            fechaini_localizada: "1/Ene/2022",
            fechafin_localizada: "31/Ene/2022",
            formulario_id: @formulario.id,

            grupoper_attributes: {
              id: nil,
              nombre: "ZZ",
            },
          },
        }
      end

      assert_redirected_to mr519_gen.encuestapersona_path(
        assigns(:encuestapersona),
      )
    end

    test "debe actualizar existente" do
      patch mr519_gen.encuestapersona_path(@encuestapersona.id),
        params: {
          encuestapersona: {
            id: @encuestapersona.id,
            adurl: "abc",
          },
        }

      assert_redirected_to mr519_gen.encuestapersona_path(assigns(:encuestapersona))
    end

    test "debe eliminar" do
      assert_difference("Encuestapersona.count", -1) do
        delete mr519_gen.encuestapersona_path(Encuestapersona.find(@encuestapersona.id))
      end

      assert_redirected_to mr519_gen.encuestaspersona_path
    end
  end
end
