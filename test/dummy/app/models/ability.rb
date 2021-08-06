# encoding: UTF-8

class Ability  < Sip::Ability

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
    # El primer argumento para can es la acción a la que se da permiso, 
    # el segundo es el recurso sobre el que puede realizar la acción, 
    # el tercero opcional es un diccionario de condiciones para filtrar 
    # más (e.g :publicado => true).
    #
    # El primer argumento puede ser :manage para indicar toda acción, 
    # o grupos de acciones como :read (incluye :show e :index), 
    # :create, :update y :destroy.
    #
    # Si como segundo argumento usa :all se aplica a todo recurso, 
    # o puede ser una clase.
    # 
    # Detalles en el wiki de cancan: 
    #   https://github.com/ryanb/cancan/wiki/Defining-Abilities


    # Sin autenticación puede consultarse información geográfica 
    can :read, [Sip::Pais, Sip::Departamento, Sip::Municipio, Sip::Clase]
    # No se autorizan usuarios con fecha de deshabilitación
    if !usuario || usuario.fechadeshabilitacion
      return
    end
    can :contar, Sip::Ubicacion
    can :buscar, Sip::Ubicacion
    can :lista, Sip::Ubicacion
    can :descarga_anexo, Sip::Anexo
    can :nuevo, Sip::Ubicacion
    if usuario && usuario.rol then
      case usuario.rol 
      when Ability::ROLANALI
        #can :read, Mr519Gen::Formulario
        can :read, [Mr519Gen::Encuestausuario, Mr519Gen::Encuestapersona]
        can [:edit, :update], 
            Mr519Gen::Encuestausuario.where(usuario_id: usuario.id)

        can :read, Sip::Orgsocial
        can :read, Sip::Persona
        can :read, Sip::Ubicacion
        can :new, Sip::Ubicacion
        can [:update, :create, :destroy], Sip::Ubicacion

      when Ability::ROLADMIN
        can :manage, [Mr519Gen::Encuestausuario, Mr519Gen::Encuestapersona]
        can :manage, Mr519Gen::Formulario

        can :manage, Sip::Orgsocial
        can :manage, Sip::Persona
        can :manage, Sip::Respaldo7z
        can :manage, Sip::Ubicacion
        
        can :manage, ::Usuario


        can :manage, :tablasbasicas
        self.tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end # def initialize

end
