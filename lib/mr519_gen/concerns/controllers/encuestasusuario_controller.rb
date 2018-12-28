# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Controllers
      module EncuestasusuarioController
        extend ActiveSupport::Concern

        included do

          before_action :set_encuestausuario, 
            only: [:show, :edit, :update, :destroy]
          #load_and_authorize_resource class: Mr519Gen::Encuestausuario
          # Mejor metodo a metodo y podrían ser solo parte de los registros

          def clase
            "Mr519Gen::Encuestausuario"
          end

          def genclase
            return 'F'
          end

          def filtrar_ca(reg)
            if cannot?(:manage, Mr519Gen::Encuestausuario)
              reg = reg.where(usuario_id: current_usuario.id)
            end
            return reg
          end

          def atributos_index
            r = [ :id ]
            if can?(:manage, Mr519Gen::Encuestausuario)
              r << :usuario
            end
            r += [ :formulario_id,
                   :fechaini_localizada, 
                   :fechacambio_localizada, 
                   :fechainicio_localizada, 
                   :fechafin_localizada,
                   :valorcampo
            ]
          end

          def atributos_form
            r = atributos_show - [:id]
            if cannot?(:manage, Mr519Gen::Encuestausuario)
              r = r - [:fechainicio_localizada, 
                       :fechafin_localizada]
            end
            return r
          end

          def atributos_show
            atributos_index
          end

          def index_reordenar(c)
            c = c.reorder('mr519_gen_encuestausuario.fecha DESC')
            return c
          end

          # GET /encuestasusuario/new
          def new
            @registro = @encuestausuario = Encuestausuario.new
            @registro.respuestafor = Respuestafor.new
            @registro.respuestafor.fechaini = Date.today
            @registro.respuestafor.fechacambio = Date.today
            @registro.usuario = current_usuario
            @registro.fechainicio = Date.today
            @registro.save!(validate: false)
            redirect_to mr519_gen.edit_encuestausuario_path(@registro)
          end

          def asegura_camposdinamicos(encuestausuario)
            if encuestausuario.nil? || encuestausuario.respuestafor.nil? ||
                encuestausuario.respuestafor.formulario.nil? 
              return
            end
            ci = encuestausuario.respuestafor.formulario.campo_ids
            cd = encuestausuario.respuestafor.valorcampo.map(&:campo_id)
            sobran = cd - ci
            borrar = encuestausuario.respuestafor.valorcampo.where(campo_id: sobran).
              map(&:id)
            encuestausuario.respuestafor.valorcampo_ids -= borrar
            puts encuestausuario.respuestafor.valorcampo_ids 
            faltan = ci - cd
            faltan.each do |f|
              vc = Mr519Gen::Valorcampo.new(
                respuestafor_id: encuestausuario.respuestafor_id, 
                campo_id: f, 
                valor: '')
              vc.save!(validate: false)
            end
          end

          def edit_mr519_gen
            @registro = Mr519Gen::Encuestausuario.find(params[:id])
            authorize! :edit, @registro
            asegura_camposdinamicos(@registro)
            @registro.save!(validate: false)
          end

          # GET /encuestasusuario/1/edit
          def edit
            edit_mr519_gen
            render layout: 'application'
          end

          private

          def set_encuestausuario
            @registro = @encuestausuario = Encuestausuario.find(
              Encuestausuario.connection.quote_string(params[:id]).to_i
            )
          end

          def lista_params
            l = atributos_form
            if l.index(:usaurio)
              l[l.index(:usuario)] = :usuario_id
            end
            if l.index(:formulario)
              l[l.index(:formulario)] = :formulario_id
            end
            l += [ :valorcampo_attributes => [
              :id,
              :campo_id,
              :valor
            ] ]
            return l
          end

          # Lista blanca de parametros
          def encuestausuario_params
            params.require(:encuestausuario).permit(lista_params)
          end

        end # included do


      end
    end
  end
end


