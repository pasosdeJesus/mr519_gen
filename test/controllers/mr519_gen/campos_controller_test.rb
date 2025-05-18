# frozen_string_literal: true

require_relative "../../test_helper"

module Mr519Gen
  class CamposControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      raise "CONFIG_HOSTS debe ser www.example.com" if ENV["CONFIG_HOSTS"] != "www.example.com"

      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)

      assert_predicate @current_usuario, :valid?
      @formulario = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)

      assert_predicate @formulario, :valid?
      @campo = Mr519Gen::Campo.new(PRUEBA_CAMPO)
      @campo.formulario = @formulario

      assert_predicate @campo, :valid?
      @campo.save!
      sign_in @current_usuario
    end

    test "debe mostrar nuevo" do
      skip
      assert_difference("Mr519Gen::Campo.count", +1) do
        debugger
        get crear_campo_url(index: 0) + "?formulario_id=#{@formulario.id}&index=0",
          as: :json
        debugger

        assert_response :success
      end
    end

    test "should destroy campo" do
      skip
      assert_difference("Mr519Gen::Campo.count", -1) do
        debugger
        delete eliminar_campo_url(@campo.id, 0), as: :json

        debugger

        assert_response :success
      end
    end
  end
end
