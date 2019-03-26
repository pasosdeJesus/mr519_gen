# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#//= require sip/motor
#//= require heb412_gen/motor
#//= require jquery-ui/widgets/autocomplete
#//= require cocoon

@mr519_gen_prepara_eventos_comunes = (root, opciones = {}) ->
  $(document).on('change', '[id^=formulario_campo_attributes_][id$=_tipo]', (event) ->
    root = exports ? window
    if $(this).find('option:selected').length > 0 && ($(this).find('option:selected').text() == 'Selección Múltiple' || $(this).find('option:selected').text() == 'Selección Simple')
      $(this).parent().parent().parent().find('.espopciones').show()
    else
      $(this).parent().parent().parent().find('.espopciones').hide()
  )
	

