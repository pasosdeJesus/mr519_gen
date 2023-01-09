require 'test_helper'

module Mr519Gen
  class EncuestasusuarioControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
      @current_usuario = 
        ::Usuario.create(PRUEBA_USUARIO) 
      assert @current_usuario.valid?
      @formulario = Mr519Gen::Formulario.create(PRUEBA_FORMULARIO)
      assert @formulario.valid?
      @respuestafor = Mr519Gen::Respuestafor.new(PRUEBA_RESPUESTAFOR)
      @respuestafor.formulario = @formulario
      @respuestafor.save!
      assert @respuestafor.valid?

      @encuestausuario = Mr519Gen::Encuestausuario.new(
        PRUEBA_ENCUESTAUSUARIO.merge(
          respuestafor_id: @respuestafor.id, 
          usuario_id: @current_usuario.id))
      assert @encuestausuario.valid?
      @encuestausuario.save!
      sign_in @current_usuario
    end

    test "debe mostrar listado" do
      get encuestasusuario_url
      assert_response :success
    end

    test "debe mostrar nuevo" do
      get new_encuestausuario_url
      assert_response 302
    end

    test "debe crear encuestausuario" do
      skip
      a = PRUEBA_ENCUESTAUSUARIO
      a[:fechainicio_localizada] = a[:fechainicio]
      a[:fecha] = a[:fechainicio]
      a[:respuestafor_attributes ] = {
        id: nil,
        valorcampo_attributes: [{valor: 1, campo_id:1}]
      }
      n1 = Mr519Gen::Encuestausuario.count
      debugger
      post encuestasusuario_url, params: { encuestausuario: a }
      debugger
      n2 = Mr519Gen::Encuestausuario.count

      assert_redirected_to encuestausuario_url(Mr519Gen::Encuestausuario.last)
    end

    test "debe mostrar encuestausuario" do
      get encuestausuario_url(@encuestausuario.id)
      assert_response :success
    end

    test "debe permitir editar" do
      get edit_encuestausuario_url(@encuestausuario.id)
      assert_response :success
    end

    test "debe actualizar encuestausuario" do
      patch encuestausuario_url(@encuestausuario.id), params: { 
        encuestausuario: {  
          fechainicio: '2018-10-10'
        } 
      }
      assert_redirected_to encuestausuario_url(@encuestausuario.id)
    end

    test "debe eliminar encuestausuario" do
      assert_difference('Mr519Gen::Encuestausuario.count', -1) do
        delete encuestausuario_url(@encuestausuario.id)
      end
      @formulario.destroy

      assert_redirected_to encuestasusuario_url
    end

  end
end
