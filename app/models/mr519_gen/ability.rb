# frozen_string_literal: true

module Mr519Gen
  class Ability < Msip::Ability
    BASICAS_PROPIAS = []

    def tablasbasicas
      Msip::Ability::BASICAS_PROPIAS +
        Mr519Gen::Ability::BASICAS_PROPIAS
    end

    NOBASICAS_INDSEQID = [
      ["Mr519Gen", "campo"],
      ["Mr519Gen", "encuestapersona"],
      ["Mr519Gen", "encuestausuario"],
      ["Mr519Gen", "formulario"],
      ["Mr519Gen", "planencuesta"],
      ["Mr519Gen", "respuestafor"],
      ["Mr519Gen", "valorcampo"],
    ]

    # Tablas no básicas pero que tienen índice *_seq_id
    def nobasicas_indice_seq_con_id
      Msip::Ability::NOBASICAS_INDSEQID +
        NOBASICAS_INDSEQID
    end

    # Se definen habilidades con cancancan
    # Util en motores y aplicaciones de prueba
    # En aplicaciones es mejor escribir completo el modelo de autorización
    # para facilitar su análisis y evitar cambios inesperados al actualizar
    # motores
    # @usuario Usuario que hace petición
    def initialize_mr519_gen(usuario = nil)
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

      initialize_msip(usuario)
      return unless usuario && usuario.rol

      case usuario.rol
      when Ability::ROLANALI
        can(:read, [Mr519Gen::Encuestausuario, Mr519Gen::Encuestapersona])
        can(
          [:edit, :update],
          Mr519Gen::Encuestausuario.where(usuario_id: usuario.id),
        )

      when Ability::ROLADMIN
        can(:manage, [
          Mr519Gen::Encuestausuario,
          Mr519Gen::Encuestapersona,
          Mr519Gen::Formulario,
          Mr519Gen::Campo,
          Mr519Gen::Opcioncs,
          Mr519Gen::Planencuesta,
        ])
      end
    end # def initialize_jn316_gen
  end # class
end # module
