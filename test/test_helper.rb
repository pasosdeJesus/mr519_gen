
require 'zeitwerk'

ENV["RAILS_ENV"] = "test"

require 'simplecov'
Zeitwerk::Loader.eager_load_all # buscando que simplecov cubra más
require_relative "dummy/config/environment"

require "rails/test_help"


module ActiveSupport
  class TestCase
  end
end


PRUEBA_CAMPO = {
  nombre: 'c',
  nombreinterno: 'c',
}

PRUEBA_ENCUESTAPERSONA = {
  persona_id: 1,
  fecha: '2018-12-01',
  adurl: 'xyz',
}

PRUEBA_ENCUESTAUSUARIO = {
  usuario_id: 1,
  fechainicio: '2018-12-01',
}


PRUEBA_FORMULARIO = {
  nombre:'n',
  nombreinterno:'n',
}

PRUEBA_PERSONA = {
  nombres:'n',
  apellidos:'n',
  sexo: 'M',
}

PRUEBA_OPCIONCS = {
  nombre: 'n',
  valor: 'v'
}

PRUEBA_PLANENCUESTA = {
  fechaini: '2023-01-02',
  fechafin: '2023-12-31',
  formulario_id: 1,
  plantillacorreoinv_id: nil,
  adurl: 'x',
  created_at: '2023-01-02',
  updated_at: '2023-01-02'
}

PRUEBA_RESPUESTAFOR = {
  fechaini: '2018-12-19',
  fechacambio: '2018-12-19',
}

PRUEBA_USUARIO= {
  nusuario: "mr519gen",
  password: "mr519gen",
  nombre: "admin",
  descripcion: "admin",
  rol: 1,
  idioma: "es_CO",
  email: "usuario1@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2018-12-19",
  fechadeshabilitacion: nil,
}


PRUEBA_VALORCAMPO = {
  valor: 1
}

