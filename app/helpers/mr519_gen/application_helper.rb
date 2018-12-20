module Mr519Gen
  module ApplicationHelper
    include ::FontAwesome::Rails::IconHelper
    include Sip::PaginacionAjaxHelper

    TEXTO = 1
    TEXTOLARGO = 2
    ENTERO = 3
    BOOLEANO = 4
    FLOTANTE = 5

    TIPOS_CAMPO = [ ['Texto', TEXTO],
                      ['Texto largo', TEXTOLARGO],
                      ['Entero', ENTERO],
                      ['Booleano', BOOLEANO],
                      ['Flotante', FLOTANTE]
    ]

  end
end
