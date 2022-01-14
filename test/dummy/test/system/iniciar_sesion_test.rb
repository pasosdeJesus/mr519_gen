require "application_system_test_case"

class IniciarSesionTest < ApplicationSystemTestCase

  def iniciar_sesion(usuario, clave)
    visit root_url
    assert_content 'Pasos de Jesús'
    click_link 'Iniciar Sesión'
    assert_content 'Usuario'
    fill_in('Usuario', with: usuario)
    fill_in('Clave', with: clave)
    find_button('Iniciar Sesión').click
    assert_content 'Sesión iniciada.'
  end

  test "iniciar sesión" do
    iniciar_sesion('mr519', 'mr519')
  end

end
