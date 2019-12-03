// Apoyo visual para el editor de formularios
// Desarrollado por Luis Alejandro Cruz luisalejo@unicauca.edu.co
// Financiado por CINEP/PPP con recursos de la Universidad de Sheffield y por JRS-LAC
// Cedido al dominio publico de acuerdo a la legislacion colombiana

var coordenadas;

function cargarCoordenadas(id, coordenada){
  $('#formulario_campo_attributes_' + id + '_fila').attr('value', coordenada.x);
  $('#formulario_campo_attributes_' + id + '_columna').attr('value', coordenada.y);
  $('#formulario_campo_attributes_' + id + '_ancho').attr('value', coordenada.width);
};

function actualizaBloque(e){
  var bloqueClickeado;
  if (e.srcElement){
    tag = e.srcElement.parentElement;}
  else if (e.target){
    tag = e.target.parentElement;}
  bloqueClickeado = tag.getAttribute('data-gs-id');
  coordenadas = obteneruna(bloqueClickeado);
  cargarCoordenadas(bloqueClickeado, coordenadas);
};

function eliminaBloque(e, idBloque){
  if (e.srcElement){
    tag = e.srcElement.parentElement;}
  else if (e.target){
    tag = e.target.parentElement;}
  enlace = tag.firstElementChild;
  enlaceClickeado = enlace.firstElementChild.getAttribute('value');
  var bloqueAEliminar = $("[data-gs-id="+enlaceClickeado+"]");
  bloqueAEliminar.remove();
};

$(document).on('cocoon:after-insert', '#campos', function(e, campo){
  var bloques = $("[data-gs-id=0]");
  var itemid = bloques.attr('data-gs-id');
  if (itemid == 0) {
    var ultimafila = e.target.lastElementChild;
    var ultimacolumna = ultimafila.lastElementChild;
    var elementoid = ultimacolumna.firstElementChild;
    var elid = elementoid.firstElementChild;
    bloques.attr('data-gs-id', elid.value);
    coordenadas = obteneruna(elid.value);
    cargarCoordenadas(elid.value, coordenadas);
  };
});

function obteneruna(identificador) {
  var serializado = $('[data-gs-id='+identificador+']');
  var item = serializado.data('_gridstack_node');
  return {
    x: item.x + 1,
    y: item.y + 1,
    width: item.width
  };
};

// Prepara visualizacion de formulario que se edita
function mr519_gen_edita_formulario_registra() {
  ko.components.register('dashboard-grid', {
    viewModel: {
      createViewModel: function (controller, componentInfo) {
        var ViewModel = function (controller, componentInfo) {
          var grid = null;
          this.widgets = controller.widgets;
          this.afterAddWidget = function (items) {
            if (grid == null) {
              grid = $(componentInfo.element).find('.grid-stack').gridstack({
                auto: false,
                resizable: { handles: 'e, w'}
              }).data('gridstack');
            }
            var item = items.find(function (i) { return i.nodeType == 1 });
            grid.addWidget(item);
            ko.utils.domNodeDisposal.addDisposeCallback(item, function () {
              grid.removeWidget(item);
            });
          };
        };
        return new ViewModel(controller, componentInfo);
      }
    },
    template:
    [
      '<div class="grid-stack" data-bind="foreach: {data: widgets, afterRender: afterAddWidget}">',
      '   <div class="grid-stack-item" data-bind="attr: {\'data-gs-x\': $data.x, \'data-gs-y\': $data.y, \'data-gs-width\': $data.width, \'data-gs-height\': $data.height,\'data-gs-min-width\': $data.minWidth, \'data-gs-auto-position\': $data.auto_position, \'data-gs-id\': $data.id}">',
      '       <div class="grid-stack-item-content"></div>',
      '   </div>',
      '</div> '
    ].join('')
  });


  $(function () {
    var Controller = function (widgets) {
      var self = this;
      this.widgets = ko.observableArray(widgets);
      this.addNewWidget = function () {
        this.widgets.push({
          x: 0,
          y: 0,
          width: Math.floor(1 + 3 * Math.random()),
          height: 1,
          minWidth: 2,
          auto_position: true,

          id: 0
        });
        return false;
      };

      $(document).on('cocoon:before-remove', '#campos', function(e, campo){
        var enlacesEliminar = $("[class=eliminaCampos]")
      });

    };
    var widgets = [];
    var controller = new Controller(widgets);
    ko.applyBindings(controller);

  });

}
