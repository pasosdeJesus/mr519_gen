/* eslint no-console:0 */

console.log('Hola Mundo desde ESM')

import Rails from "@rails/ujs";
import "@hotwired/turbo-rails";
Rails.start();
window.Rails = Rails

import "./jquery"

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
import 'gridstack'

import TomSelect from 'tom-select';
window.TomSelect = TomSelect;
window.configuracionTomSelect = {
  create: false,
  diacritics: true, //no sensitivo a acentos
  sortField: {
    field: "text",
    direction: "asc"
  }
}

import Msip__Motor from "./controllers/msip/motor"
window.Msip__Motor = Msip__Motor
Msip__Motor.iniciar()
import Mr519Gen__Motor from "./controllers/mr519_gen/motor"
window.Mr519Gen__Motor = Mr519Gen__Motor


import {AutocompletaAjaxExpreg} from '@pasosdejesus/autocompleta_ajax'
window.AutocompletaAjaxExpreg = AutocompletaAjaxExpreg

import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'

let esperarRecursosSprocketsYDocumento = function (resolver) {
  if (typeof window.puntomontaje == 'undefined') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  if (document.readyState !== 'complete') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  resolver("Recursos manejados con sprockets cargados y documento presentado en navegador")
    return true
  }

let promesaRecursosSprocketsYDocumento = new Promise((resolver, rechazar) => {
  esperarRecursosSprocketsYDocumento(resolver)
})

promesaRecursosSprocketsYDocumento.then((mensaje) => {
  console.log(mensaje)
  var root;
  root = window;

  Msip__Motor.ejecutarAlCargarDocumentoYRecursos()  // Este se ejecuta cada vez que se carga una página que no está en cache y tipicamente después de que se ha cargado la página completa y los recursos
  msip_prepara_eventos_comunes(root);
  mr519_gen_prepara_eventos_comunes(root);
})


document.addEventListener('turbo:load', (e) => {
 /* Lo que debe ejecutarse cada vez que turbo cargue una página,
 * tener cuidado porque puede dispararse el evento turbo varias
 * veces consecutivas al cargarse  la misma página.
 */
  
  console.log('Escuchador turbo:load')

  msip_ejecutarAlCargarPagina(window) // Establece root.puntomontaje
  Msip__Motor.ejecutarAlCargarPagina()
  Mr519Gen__Motor.ejecutarAlCargarPagina()
})



import "./controllers"
