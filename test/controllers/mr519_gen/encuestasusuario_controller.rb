require_relative '../../test_helper'
require_relative '../../models/mr519_gen/encuestausuario_test.rb'

module Mr519Gen
  class EncuestasusuarioControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers
    
    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
      @current_usuario = 
        ::Usuario.create(Mr519Gen::EncuestausuarioTest::PRUEBA_USUARIO) 
      assert @current_usuario.valid?
      @formulario = Mr519Gen::Formulario.create(
        ::Mr519Gen::FormularioTest::PRUEBA_FORMULARIO)
      assert @formulario.valid?
      @encuestausuario = Mr519Gen::Encuestausuario.new(
        Mr519Gen::EncuestausuarioTest::PRUEBA_ENCUESTAUSUARIO)
      @encuestausuario.formulario = @formulario
      @encuestausuario.usuario = @current_usuario
      assert @encuestausuario.valid?
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
      a = Mr519Gen::EncuestausuarioTest::PRUEBA_ENCUESTAUSUARIO
      a[:fecha_localizada] = a[:fecha]
      assert_difference('Mr519Gen::Encuestausuario.count') do
        post encuestasusuario_url, params: { 
          encuestausuario: Mr519Gen::EncuestausuarioTest::PRUEBA_ENCUESTAUSUARIO
        }
      end

      assert_redirected_to encuestausuario_url(Mr519Gen::Encuestausuario.last)
    end

    test "should show encuestausuario" do
      get encuestausuario_url(@encuestausuario)
      assert_response :success
    end

    test "should get edit" do
      get edit_encuestausuario_url(@encuestausuario)
      assert_response :success
    end

    test "should update encuestausuario" do
      patch encuestausuario_url(@encuestausuario), params: { 
        encuestausuario: {  
          fecha: '2018-10-10'
        } 
      }
      assert_redirected_to encuestausuario_url(@encuestausuario)
    end

    test "should destroy encuestausuario" do
      assert_difference('Mr519Gen::Encuestausuario.count', -1) do
        delete encuestausuario_url(@encuestausuario)
      end
      @formulario.destroy

      assert_redirected_to encuestasusuario_url
    end

#    test "enrutamiento" do
#      assert_routing "/encuestasusuario", controller: "cor1440_gen/encuestasusuario", 
#        action: "index"
#    end
    

  end
end
