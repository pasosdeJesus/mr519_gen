# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#//= require msip/motor
#//= require cocoon
#//= require mr519_gen/edita_formulario

@mr519_gen_nombre_a_nombreinterno = (nombre) ->
  ni = nombre.replace(/[^A-Za-z0-9_]/g, '_') 
  ni = ni.toLowerCase()
  ni = ni.substring(0, 60)
  ni

@mr519_gen_prepara_eventos_comunes = (root, opciones = {}) ->
  $(document).on('change', '[id^=formulario_campo_attributes_][id$=_tipo]', (event) ->
    root = window
    if $(this).find('option:selected').length > 0 && ($(this).find('option:selected').text() == 'Selección Múltiple' || $(this).find('option:selected').text() == 'Selección Simple')
      $(this).parent().parent().parent().find('.espopciones').show()
    else
      $(this).parent().parent().parent().find('.espopciones').hide()
    if $(this).find('option:selected').length > 0 && ($(this).find('option:selected').text() == 'Selección Múltiple con Tabla Básica' || $(this).find('option:selected').text() == 'Selección Simple con Tabla Básica')
      $(this).parent().parent().parent().find('.tablabasica').show()
    else
      $(this).parent().parent().parent().find('.tablabasica').hide()

  )

  $(document).on('change', '#formulario_nombre', (event) ->
    root = window
    idni = $(this).attr('id').replace('nombre', 'nombreinterno')
    if  $('#' + idni).length == 1 && ($('#' + idni).val() == '' || $('#' + idni).val() == 'N')
      $('#' + idni).val(mr519_gen_nombre_a_nombreinterno($(this).val()))
  )

  # Cubre tanto nombre de campos como nombre de opciones
  $(document).on('change', 'input[id^=formulario_campo_attributes_][id$=_nombre]', (event) ->
    root = window
    idni = $(this).attr('id').replace('nombre', 'nombreinterno')
    if  $('#' + idni).length == 0
      idni = $(this).attr('id').replace('nombre', 'valor')
    if  $('#' + idni).length == 1 && ($('#' + idni).val() == '' || $('#' + idni).val() == 'N')
      $('#' + idni).val(mr519_gen_nombre_a_nombreinterno($(this).val()))
  )

  if  $('.grid-stack').length > 0
    mr519ef_prepara();

  0



