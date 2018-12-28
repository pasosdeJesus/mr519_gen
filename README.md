# Motor Mr519Gen para crear formularios y ayudar a aplicarlos

[![Esado Construcción](https://api.travis-ci.org/pasosdeJesus/mr519_gen.svg?branch=master)](https://travis-ci.org/pasosdeJesus/mr519_gen) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/mr519_gen/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/mr519_gen) [![security](https://hakiri.io/github/pasosdeJesus/mr519_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/mr519_gen/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/mr519_gen.svg)](https://gemnasium.com/pasosdeJesus/mr519_gen) 

Este motor Mr519Gen permite crear formularios y ayudar a aplicarlos

## 1. Aspectos metodológicos

Para ayudar a caracterizar los instrumentos para recolectar información:

| 1. Tipo de instrumento | |
| 2. Nombre del instrumento | |
| 3. A quien va dirigido | |
| 4. Quien sistematiza | |
| 5. Que sistematiza | |
| 6. Se recolectan datos personales | |
| 7. Vigencia para sistematizar | |
| 8. Como sistematiza | |
| 9. Quien revisa/verifica | |
| 10. Que revisa/verifica | |
| 11. Cómo revisar/verifica | |
| 12. A quien y como informa problemas | |
| 12. Quien corrige | |
| 13. Como corrige | |
| 14. Que se hace con la información recolectada | |


## 2. Aspectos técnicos

Aplican practicamente las mismas instrucciones de otros motores genéricos
basados en sip, ver por ejemeplo:
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

