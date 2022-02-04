# Motor Mr519Gen para crear formularios y ayudar a aplicarlos


[![Revisado por Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com) Pruebas y seguridad: [![Estado Construcción](https://gitlab.com/pasosdeJesus/mr519_gen/badges/v2.0/pipeline.svg)](https://gitlab.com/pasosdeJesus/mr519_gen/-/pipelines?page=1&scope=all&ref=v2.0) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen)

![Logo de mr519_gen](https://raw.githubusercontent.com/pasosdeJesus/mr519_gen/master/test/dummy/app/assets/images/logo.jpg)

Este motor Mr519Gen permite crear formularios y ayudar a aplicarlos

## 1. Aspectos metodológicos

Para ayudar a caracterizar los instrumentos para recolectar información:

| Aspecto | Algunas posibilidades |
|---------|-----------------------|
| 1. Tipo de instrumento | (a) Encuesta/Cuestionario, (b) Entrevista/Caracterización, (c) Grupo focal |
| 2. Nombre del instrumento | |
| 3. ¿A quién va dirigido? (fuente de información) | (a) Usuarios del sistema o un grupo, (b) Beneficiarios de un proyecto, (c) Contactos con actores sociales |
| 4. ¿Quién sistematiza? | (a) Cada usuario, (b) Un usuario, (c) Personas sin usuario y clave en sistema, (d) Beneficiarios de un proyecto con usuario y clave temporal a instrumento(s) de sistematización |
| 5. ¿Qué sistematiza y con qué validaciones automáticas? | |
| 6. ¿Se recolectan datos personales? (en caso afirmativo mensaje de protección de datos personales por usar) | |
| 7. ¿Vigencia para sistematizar? | Fecha inicio, fecha fin |
| 8. ¿Cómo sistematiza? | (a) Ingresa al sistema y desde cierta ubicación en el mismo, (b) Recibe URL por correo, (c) |
| 9. ¿Quién revisa/verifica? | |
| 10. ¿Qué revisa/verifica? | |
| 11. ¿Cómo revisar/verifica? | |
| 12. ¿A quién y cómo informar problemas? | |
| 13. ¿Quién corrige? | |
| 14. ¿Cómo corrige? | |
| 15. ¿Qué se hace con la información recolectada? | (a) Aportar a la medición de indicadores, (b) generar tabla |


## 2. Aspectos técnicos

Aplican practicamente las mismas instrucciones de otros motores genéricos
basados en sip, ver por ejemplo:
	https://github.com/pasosdeJesus/sal7711_gen

Para incluirlo en su aplicación rails que ya usa sip, tenga en cuenta que deben incluirse CSS y Javascript sin módulos servidos por sprockets y además otro Javascript con módulos servido por Webpacker y paquetes manejados por yarn.

1. Agregue las gemas necesarias en Gemfile:
```
	gem 'mr519_gen', git: 'https://github.com/pasosdeJesus/mr519_gen.git'
```
2. Agregue los paquetes npm típicos requeridos por `sip` (ver <https://github.com/pasosdeJesus/sip/blob/master/doc/iniciar-si-usando-sip.md>) y además:
```
CXX=c++ yarn add gridstack
CXX=c++ yarn install
```
3. Asegure que en su archivo `app/javascript/packs/application.js` incluye `jquery`, `jquery-ui` y de `jquery-ui` que incluye `ui/data` y `ui/focusable`.  Es decir puede ser algo como:
```
require("@rails/ujs").start() 
require("turbolinks").start() 
 
import {$, jQuery} from "jquery"; 
 
import "popper.js" 
import "bootstrap" 
import "chosen-js/chosen.jquery" 
import 'bootstrap-datepicker' 
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js' 
import 'jquery-ui' 
import 'jquery-ui/ui/widgets/autocomplete' 
import 'jquery-ui/ui/data' 
import 'jquery-ui/ui/focusable'
```
4. Incluya el motor javascript en su app/assets/javascript/application.js
   por ejemplo después de ```//= require sip/motor``` agregue:
```
//= require mr519_gen/motor
```
   y despúes de ```sip_prepara_eventos_comunes...``` agregue:
```
mr519_gen_prepara_eventos_comunes(root);
```
5. Incluya los CSS de mr519 agregando en `app/assets/stylesheets/application.css` la línea:
```
 *= require mr519_gen/application.css
```
6. Configure su aplicación para enlazar al gestor de formularios 
   con rutas como `mr519_gen.formularios_path` 

7. Configure enlaces a encuestas a usuarios por ejemplo con rutas como
   `mr519_gen.encuestasusuario_path`

## 3. Desarrollo

Para un nuevo tipo de campo.

1. Agreguelo en `app/helpers/mr519_gen/application_helper.rb` como una constante (sin repetir número) y la constante agregela al arreglo `TIPOS_CAMPO`
2. Si la especificación del campo requiere información adicional modificar
`app/views/mr519_gen/formularios/_campo_campos.html.erb` (eventualmente junto
con el controlador `app/controllers/mr519_gen/formularios_controller.rb`)
3. Agregar como lo verá quien llene la encuesta en `app/views/mr519_gen/formularios/_campodinamico.html.erb`. Para almacenar la información la tabla `mr519_gen_valorcampo` tiene 2 campos: `valor` (cadena de 5000) y `valorjson` (campo
json).  
4. Puede usar un atributo virtual (como valor_ids) que convierta el parámetro 
que produzca el campo al valor por guardar en la base de datos.

