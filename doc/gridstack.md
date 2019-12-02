# Gestor gráfico para creación de Formulario

PROPUESTA: GRIDSTACK (Seleccionada)

La pru

Gridstackjs, acceda a la docmunetación [Aquí](https://github.com/gridstack/gridstack.js/tree/develop/doc)

Para la implementación de esta tecnología es necesario investigar a fondo la documentación de [Cocoon](https://github.com/nathanvda/cocoon) que es la gema utilizada para la creación de formularios anidados y además la documenación de [knockout](https://knockoutjs.com/) muy útil en gridstack para la gestión de los items.

Tópicos a Investigar en el transcurso del desarrollo:

1. Cómo limitar la propiedad resizable en gridstack, para que solo se pueda modificar el ancho y no el alto.

En esta investigación se encontró en la documentación que es posible configurar la propiedad resizable para establecer hacia que lado se puede modificar el tamaño del item. para este caso se debe configurar como resizable: { handles: 'e, w'} deteminando que solo es posible modificar sus lado derecho e izquierdo. 

2. Cómo obtener las coordenadas de posición y el valor del ancho de cada bloque agregado al canvas.

Para este problema planteado se revisó uno de los demos denominado [serialization](https://gridstackjs.com/demo/serialization.html) ofrecidos por gridstack en donde al final se exportan los datos y se guardaban en un formato json con coordneadas de cada item y el alto y el ancho, en principio s epiensa que puede ser uil, sin embargo este ejemplo exporta las coordenas en su totalidad, y lo que se busca es de un iten en específico. Así que para esto se encontró finalmente que es posible llamar al item por un identificador específico y extraerle sus propiedades x, y, y width para la fila, columna y ancho respectivamente.

3. Cómo actúa knockout en la creación y los eventos de drag and drop en gridstackjs, para acceder a las propiedades de los items.

La librería knockout ya documentada arriba es importante para las funciones de agregar, funciones despues de agregar y funciones de eliminar items. A través de Vista-modelo (viewmodel), gridistack constantemente actualiza el estado de la grilla y sus ítems con cada una de sus propiedades. Ademásen la variable template se dan las instrucciones del diseño de los ítems que en este caso son divs.  

4. Qué funciones se encargan de agregar y eliminar un item.

Para entender cómo gridstack agrega los ítems y los elimina, se identifican las funciones addWidget() y remove(). COn estaas funciones y en unión a lo definido en knockout se piensa en un array de items el cual va creciendo de tamaño con el evento push que va agregando el item creado. Para eliminar solo basta con definir  el item a liminar dentro del evento remove.

5. Cómo caracterizar el item creado de gridstack con el campo creado de cocoon. 

Para eso se piensa en la idea de asignarle una propiedad al item que tenga el valor del id oculto de cada campo. para eso se hace uso del atributo data-gs-id en gridstack. Para saber el id del campo creado, a través de target se extrae la etiqueta del ulitmo hijo de la tabla y se extra el atributo id de aquella fila.

6. Cómo hacer uso del evento cocoon:after-insert, para gestionar la creación del item desde la creación del campo.

Teniendo el identificador del nuevo campo es posible asignarlo a un item siempre y cuando este item tenga un identificador cero, de esta manera se estan cmparando los identificadores constantemente y se actualiza el atributo data-gs-id del div del item creado.

7. Cómo mostrar en los valores del formulario en fila columna y ancho, los valores obtenidos del item, y que estos se vayan actualizando constantemente.

En principio esta continua lectura de coordenadas y anho del item, y el despliegue de esta información en los campos del formulario pensó que tenía que hacerse con un binding, apra que a nivel visual siempre se actualizara cuando cambie una de las propiedades del item. Sin embargó se encontró una forma más facil, que es leer ls propiedades del iem siempre que se haga clic sobre dicho item, es decir siempre que sea modificada su posición o su ancho. La función se ejecuto al soltar el clic (onmouseup) ya que este es el estado final y en esta función es posible enviar los 3 valores del item a los 3 valores de los input del formulario. 

8. Cómo borrar un item desde el enlace eliminar de cocoon. 

La última investigación busca que el enlace de cocoon link_to_remove_association permita también eliminar el item correspondiente a ese campo. Para  esto, y haciendo uso del identificador creado y la función de detectar clic, se detecta el enlace a que se le da click, se lee el identificador de ese campo y posteriormente se envía dicho identificadora la función remove para eliminar el ítem correspondiente. 
