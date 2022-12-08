// Ahora gridstack se carga como módulo


// Pasa ubicaciones de elementos del formulario del
// esquema visual al esquema texto
function mr519ef_visual_a_texto() {
  document.querySelectorAll('.grid-stack-item').forEach((i) => {
    var vx = i.getAttribute('data-gs-x');
    var vy = i.getAttribute('data-gs-y');
    var vwidth = i.getAttribute('data-gs-width');
    if (!i.getAttribute('class').includes('grid-stack-placeholder')) {
      var vid = +i.getAttribute('data-gs-id');
      $('#formulario_campo_attributes_' + vid + '_fila').attr('value', 
        +vy + 1);
      $('#formulario_campo_attributes_' + vid + '_columna').attr('value', 
        +vx + 1 );
      $('#formulario_campo_attributes_' + vid + '_ancho').attr('value', 
        +vwidth);
    }
  })
}
 
// Pasa ubicaciones de elementos del formulario del
// esquema texto al esquema visual
function mr519ef_texto_a_visual() {
  document.querySelectorAll('[id^=formulario_campo_attributes_][id$=_id]').forEach((i) => {
    console.log(i)
    if (i.parentElement.parentElement.parentElement.getAttribute('style') === null  || !i.parentElement.parentElement.parentElement.getAttribute('style').includes('display: none')) {
      // No agrega a esquema visual los eliminados
      if (i.getAttribute('id').split('_')[4] == 'id'){
        let idc = i.getAttribute('id').split('_')[3]
        let vx = +document.querySelector('#formulario_campo_attributes_' + idc + 
          '_columna').value
        let vy = +document.querySelector('#formulario_campo_attributes_' + idc + 
          '_fila').value
        let vancho = +document.querySelector('#formulario_campo_attributes_' + 
          idc + '_ancho').value
        let vnombre = msip_escapaHtml(
          document.querySelector('#formulario_campo_attributes_' + 
          idc + '_nombre').value
        )

        document.addNewWidget({
          x: vx > 0 ? vx - 1 : 0,
          y: vy > 0 ? vy - 1 : 0,
          width: vancho > 0 ? vancho : 12,
          height: 1,
          minWidth: 1,
          auto_position: true,
          id: idc,
          contenido: vnombre ,
        })
      }
    }
  })
}

// Prepara esquema visual de formulario y sincronización con esquema texto
// y configura primer esquema visual con esquema texto desplegado
function mr519ef_prepara() {

  var opciones = {
    float: true,
    auto: false,
    resizable: { handles: 'e, w'},
  };
  if (typeof $.fn.gridstack === 'undefined') {
    return
  }

  $('.grid-stack').gridstack(opciones);
  document.grid = $('.grid-stack').data('gridstack');

  document.addNewWidget = function (datos = null) {
    var node = {
      x: 12 * Math.random(),
      y: 5 * Math.random(),
      width: 1 + 3 * Math.random(),
      height: 1,
    };
    if (datos != null) {
      node = {
        x: datos.x,
        y: datos.y,
        width: datos.width,
        height: 1,
        auto_position: true,
        id: datos.id
      };
    }
    document.grid.addWidget($('<div><div class="grid-stack-item-content">' +
      datos.contenido + '</div></div>'), node);
    return false;
  }.bind(document);  


  $(document).on('cocoon:after-insert', '#campos', function(e, campo){
    if (e.target.id == "campos") { 
      var ultimaFila = e.target.lastElementChild;
      var ultimaColumna = ultimaFila.lastElementChild;
      var elementoId = ultimaColumna.firstElementChild;
      var laid = elementoId.firstElementChild.value
      var maxy = 0
      document.querySelectorAll('.grid-stack-item').forEach( i => {
        y = +i.getAttribute('data-gs-y')
        if (y > maxy) {
          maxy = y
        }
      })
      var node = {
        x: 0,
        y: maxy,
        width: 12,
        height: 1,
        minWidth: 1,
        auto_position: true,
        id: laid,
        contenido: laid
      }
      document.grid.addWidget($('<div><div class="grid-stack-item-content">' +
        node.contenido + '</div></div>'), node);
    }
  });

  $(document).on('cocoon:after-remove', '#campos', function(e, campo){
    if (e.target.id == "campos") { 
      document.grid.removeAll()
      mr519ef_texto_a_visual()
    }  
  })

  $(document).on('change', '#campos',function(event, items) {
    if (event.target.id == "campos") { 
      document.grid.removeAll()
    mr519ef_texto_a_visual()
    }
  })

  $(document).on('change', '.grid-stack',function(event, items) {
    mr519ef_visual_a_texto()
  })

  mr519ef_texto_a_visual();

}

