# frozen_string_literal: true

require "test_helper"

module Mr519Gen
  class PlanesencuestaControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers
    # include Cocoon::ViewHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @current_usuario = ::Usuario.find(1)
      sign_in @current_usuario
      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)
      assert @formulario.valid?
      @planencuesta =  Mr519Gen::Planencuesta.create!(
        PRUEBA_PLANENCUESTA.merge(formulario_id: @formulario.id))
      assert @planencuesta.valid?
    end

    # Cada prueba que se ejecuta se hace en una transacción
    # que después de la prueba se revierte

    test "debe presentar listado" do
      get mr519_gen.planesencuesta_path

      assert_response :success
      assert_template :index
    end

    test "debe presentar resumen de existente" do
      get mr519_gen.planencuesta_url(@planencuesta.id)

      assert_response :success
      assert_template :show
    end

    test "debe presentar formulario para nueva" do
      get mr519_gen.new_planencuesta_path

      assert_response :success
      assert_template :new
    end

    test "debe presentar formulario de edición" do
      get mr519_gen.edit_planencuesta_path(@planencuesta)

      assert_response :success
      assert_template :edit
    end

    test "debe crear nueva" do
      # Arreglamos indice
      #Msip::Planencuesta.connection.execute(<<-SQL.squish)
      #  SELECT setval('public.mr519_gen.planencuesta_id_seq', MAX(id))#{" "}
      #    FROM public.mr519_gen.planencuesta;
      #SQL
      assert_difference("Planencuesta.count") do
        post mr519_gen.planesencuesta_path, params: {
          planencuesta: {
            id: nil,
            fechaini_localizada: '1/Ene/2022',
            fechafin_localizada: '31/Ene/2022',
            formulario_id: @formulario.id,

            grupoper_attributes: {
              id: nil,
              nombre: "ZZ",
            },
          },
        }
      end

      assert_redirected_to mr519_gen.planencuesta_path(
        assigns(:planencuesta),
      )
    end

    test "debe actualizar existente" do
      patch mr519_gen.planencuesta_path(@planencuesta.id),
        params: {
          planencuesta: {
            id: @planencuesta.id,
            fechaini_localizada: '2/Ene/2023',
            fechafin_localizada: '31/Ene/2023'
          },
        }

      assert_redirected_to mr519_gen.planencuesta_path(assigns(:planencuesta))
    end

    test "debe eliminar" do
      assert_difference("Planencuesta.count", -1) do
        delete mr519_gen.planencuesta_path(Planencuesta.find(@planencuesta.id))
      end

      assert_redirected_to mr519_gen.planesencuesta_path
    end
  end
end
