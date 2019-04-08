# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#//= require sip/motor
#//= require heb412_gen/motor
#//= require jquery-ui/widgets/autocomplete
#//= require cocoon

@mr519_gen_nombre_a_nombreinterno = (nombre) ->
  ni = nombre.replace(/[^A-Za-z0-9_]/g, '_') 
  ni = ni.toLowerCase()
  ni = ni.substring(0, 60)
  ni
	
@mr519_gen_prepara_eventos_comunes = (root, opciones = {}) ->
  $(document).on('change', '[id^=formulario_campo_attributes_][id$=_tipo]', (event) ->
    root = exports ? window
    if $(this).find('option:selected').length > 0 && ($(this).find('option:selected').text() == 'Selección Múltiple' || $(this).find('option:selected').text() == 'Selección Simple')
      $(this).parent().parent().parent().find('.espopciones').show()
    else
      $(this).parent().parent().parent().find('.espopciones').hide()
  )
  $(document).on('change', '[id^=formulario_campo_attributes_][id$=_nombre]', (event) ->
    root = exports ? window
    idni = $(this).attr('id').replace('nombre', 'nombreinterno')
    if  $('#' + idni).length == 1 && $('#' + idni).val() == 'n'
      $('#' + idni).val(mr519_gen_nombre_a_nombreinterno($(this).val()))
  )
	


