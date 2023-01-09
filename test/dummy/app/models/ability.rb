class Ability  < Mr519Gen::Ability

  ROLOPERADOR = 5

  ROLES = [
    ["Administrador", ROLADMIN], #1
    ["Operador", ROLOPERADOR] #5
  ]

  # Se usa desde 1
  ROLES_CA = [
    'Administrar formularios. ' +
    'Administrar encuestas. ' +
    'Administrar tablas básicas (actores sociales, tipos de convenios, etc). ' +
    'Administrar usuarios. ', #ROLADMIN, 1

    '', #2

    '', #ROLDIR, 3

    '', #4

    'Ver listado de usuarios y su información pública. ' +
    'Responder encuestas que le han aplicado. ' #ROLOPERADOR, 5
  ]


  # Se definen habilidades con cancancan
  # @usuario Usuario que hace petición
  def initialize(usuario = nil)
    super()
    initialize_mr519_gen(usuario)
  end # def initialize

end
