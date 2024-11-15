export default class Mr519Gen__Motor {
  /* 
   * Librería de funciones comunes.
   * Aunque no es un controlador lo dejamos dentro del directorio
   * controllers para aprovechar método de msip para compartir controladores
   * Stimulus de motores.
   *
   * Como su nombre no termina en _controller no será incluido en 
   * controllers/index.js
   *
   * Desde controladores stimulus importelo con
   *
   *  import Mr519Gen__Motor from "../mr519_gen/motor"
   *
   * Use funciones por ejemplo con
   *
   *  Mr519Gen__Motor.ejecutarAlCargarPagina()
   *
   * Para poderlo usar desde Javascript global con window.Mr519Gen__Motor 
   * asegure que en app/javascript/application.js ejecuta:
   *
   * import Mr519Gen__Motor from './controllers/mr519_gen/motor.js'
   * window.Mr519Gen__Motor = Mr519Gen__Motor
   *
   */

  // Se ejecuta cada vez que se carga una página que no está en cache
  // y tipicamente después de que se ha cargado la página y los recursos.
  static ejecutarAlCargarDocumentoYRecursos() {
    console.log("* Corriendo Mr519Gen__Motor::ejecutarAlCargarDocumentoYRecursos()")

    document.addEventListener('change', event => {
      if (event.target.matches("[id^=formulario_campo_attributes_]") &&
        event.target.matches("[id$=tipo]") ) {
        if (this.querySelectorAll('option:selected').length > 0 && (
          this.querySelector('option:selected').innerText == 'Selección Múltiple' || 
          this.querySelector('option:selected').innerText == 'Selección Simple')) {
          this.parentElement.parentElement.parentElement.querySelector('.espopciones').style.display = 'block'
        } else {
          this.parentElement.parentElement.parentElement.querySelector('.espopciones').style.display = 'none'
        }
        if (this.querySelectorAll('option:selected').length > 0 && (
          this.querySelector('option:selected').innerText == 'Selección Múltiple con Tabla Básica' || 
          this.querySelector('option:selected').innerText == 'Selección Simple con Tabla Básica')) {
          this.parentElement.parentElement.parentElement.querySelector('.tablabasica').style.display = "block"
        } else {
          this.parentElement.parentElement.parentElement.querySelector('.tablabasica').style.display = "none"
        }
      } else if (event.target.id == "formulario_nombre") {
        idni = $(this).attr('id').replace('nombre', 'nombreinterno')
        if  (document.querySelectorAll('#' + idni).length == 1 && (
          document.querySelector('#' + idni).value == '' || 
          document.querySelector('#' + idni).value == 'N')) {
          document.querySelector('#' + idni).value = Mr519__Motor.nombreANombreInterno(this.value)
        }
      } else if (event.target.matches("[id^=formulario_campo_attributes_]") &&
        event.target.matches("[id$=_nombre]") ) {
        // Cubre tanto nombre de campos como nombre de opciones
        idni = this.getAttribute('id').replace('nombre', 'nombreinterno')
        if  (document.querySelectorAll('#' + idni).length == 0) {
          idni = this.getAttrribute('id').replace('nombre', 'valor')
        }
        if  (document.querySelectorAll('#' + idni).length == 1 && (
          document.querySelector('#' + idni).value == '' || 
          document.querySelector('#' + idni).value == 'N')) {
          document.querySelector('#' + idni).value = Mr519__Motor.nombreANombreInterno(this.value)
        }
      }
    })

    if  (document.querySelectorAll('.grid-stack').length > 0) {
      Mr519__EditaFormulario.preparar();
    }

  }

  // Llamar cada vez que se cargue una página detectada con turbo:load
  // Tal vez en cache por lo que podría no haberse ejecutado iniciar 
  // nuevamente.
  // Podría ser llamada varias veces consecutivas por lo que debe detectarlo
  // para no ejecutar dos veces lo que no conviene.
  static ejecutarAlCargarPagina() {
    console.log("* Corriendo Mr519Gen__Motor::ejecutarAlCargarPagina()")

  }


  // Se ejecuta desde app/javascript/application.js tras importar el motor
  static iniciar() {
    console.log("* Corriendo Mr519Gen__Motor::iniciar()")
  }


  static nombreANombreInterno(nombre) {
    ni = nombre.replace(/[^A-Za-z0-9_]/g, '_') 
    ni = ni.toLowerCase()
    ni = ni.substring(0, 60)
    return ni
  }


}
