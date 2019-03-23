# Motor Mr519Gen para crear formularios y ayudar a aplicarlos

[![Esado Construcción](https://api.travis-ci.org/pasosdeJesus/mr519_gen.svg?branch=master)](https://travis-ci.org/pasosdeJesus/mr519_gen) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen) [![security](https://hakiri.io/github/pasosdeJesus/mr519_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/mr519_gen/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/mr519_gen.svg)](https://gemnasium.com/pasosdeJesus/mr519_gen) 

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
| 5. ¿Qué sistematiza y con qué validaciones automáticas?) | |
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

Para incluirlo en su aplicación rails que ya usa sip:
1. Agregue las gemas necesarias en Gemfile:
```
	gem 'mr519_gen', git: 'https://github.com/pasosdeJesus/mr519_gen.git'
	gem 'font-awesome-rails'
	gem 'chosen-rails'
	gem 'rspreadsheet'
```

2. Incluya el motor javascript en su app/assets/javascript/application.js
   por ejemplo después de ```//= require sip/motor``` agregue:
```
//= require mr519_gen/motor
```
   y despúes de ```sip_prepara_eventos_comunes...``` agregue:
```
mr519_gen_prepara_eventos_comunes(root);
```

3. Configure su aplicación para enlazar al gestor de formularios 
   con rutas como mr519_gen.formularios_path 

4. Configure enlaces a encuestas a usuarios por ejemplo con rutas como
   mr519_gen.encuestasusuario_path

## 3. Desarrollo

Para un nuevo tipo de campo.

Agregarlo a app/helpers/mr519_gen/application_helper.rb tanto constante como en
arreglo TIPOS_CAMPO

Si la especificación del campo requiere información adicional modificar
app/views/mr519_gen/formularios/_campo_campos.html.erb (eventualmente junto
con el controlador app/controllers/mr519_gen/formularios_controller.rb)

Agregar como lo verá quien llene la encuesta en app/views/mr519_gen/formularios/_campodinamico.html.erb

    k
