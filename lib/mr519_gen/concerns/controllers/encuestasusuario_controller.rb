module Mr519Gen
  module Concerns
    module Controllers
      module EncuestasusuarioController
        extend ActiveSupport::Concern

        included do

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
              r += [ :usuario,
                      :fechaini_localizada, 
                      :fechainicio_localizada ]
            end
            r += [ :formulario,
                   :fechacambio_localizada, 
                   :fechafin_localizada,
            ]
          end

          def atributos_form
            r = atributos_show - [:id, :formulario]
            r += [:formulario_id]
            if cannot?(:manage, Mr519Gen::Encuestausuario)
              r -= [
                :fechainicio_localizada, 
                :fechafin_localizada
              ]
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


          def edit_mr519_gen
            @registro = Mr519Gen::Encuestausuario.find(params[:id])
            authorize! :edit, @registro
            ::Mr519Gen::ApplicationHelper::asegura_camposdinamicos(
              @registro, current_usuario.id)
            @registro.save!(validate: false)
          end

          # GET /encuestasusuario/1/edit
          def edit
            edit_mr519_gen
            render layout: 'application'
          end

          def update
            params[:encuestausuario][:fechacambio_localizada] = 
              Msip::FormatoFechaHelper::fecha_estandar_local(Date.today)
            update_gen
          end

          def creartodousuario
            if !params || !params[:encuestausuario_id]
              render inline: 'Falta parámetro encuestausuario_id'
              return
            end
            if Mr519Gen::Encuestausuario.where(id: params[:encuestausuario_id].to_i).count != 1
              render inline: "Se esperaba una encuesta con id #{params[:encuestausuario_id].to_i}"
              return
            end
            e = Mr519Gen::Encuestausuario.find(params[:encuestausuario_id].to_i)
            lu = ::Usuario.where(
              "id NOT IN (SELECT DISTINCT usuario_id " +
              " FROM mr519_gen_encuestausuario AS eu" +
              " JOIN mr519_gen_respuestafor AS rf ON eu.respuestafor_id=rf.id"+
              " WHERE rf.formulario_id= ? AND eu.fechainicio=? " +
              " AND eu.fechafin = ?)", e.formulario_id, e.fechainicio, 
              e.fechafin)

            numu = 0 
            lu.each  do |u|
              ne = Encuestausuario.new
              ne.usuario_id = u.id
              ne.fechainicio = e.fechainicio
              ne.fechafin = e.fechafin
              ne.respuestafor = Respuestafor.new
              ne.respuestafor.fechaini = Date.today
              ne.respuestafor.fechacambio = Date.today
              ne.respuestafor.formulario_id = e.formulario_id
              ne.respuestafor.save!(validate: false)
              ne.save!(validate: false)
              numu += 1
            end
            redirect_to encuestausuario_path(e), 
              notice:  "Creadas encuestas para #{numu} usuarios"
          end

          def resultados_antes_presentar(formulario_id)
          end


          def resultados
            if !params || !params[:encuestausuario_id]
              render inline: 'Falta parámetro encuestausuario_id'
              return
            end
            eu = Encuestausuario.find(params[:encuestausuario_id].to_i)
            fid = eu.respuestafor.formulario_id
            authorize! :resultados, Mr519Gen::Formulario.find(fid)
            @registros = Encuestausuario.joins(:respuestafor).
              where("mr519_gen_respuestafor.formulario_id" => fid)
            @titulo = ''
            @consolidado = []
            menserr = ''
            if !Mr519Gen::ApplicationHelper.analiza_respuestas(
              @registros.map(&:respuestafor_id),
              @titulo,
              @consolidado,
              menserr)
              render inline: menserr
              return
            end
            resultados_antes_presentar(fid)
            @usuarios = @registros.map(&:usuario)
            render 'resultados', layout: 'application'
          end 

          private

          def set_encuestausuario
            @registro = @encuestausuario = Encuestausuario.find(
              Encuestausuario.connection.quote_string(params[:id]).to_i
            )
          end

          def lista_params
            l = atributos_form
            if l.index(:usuario)
              l[l.index(:usuario)] = :usuario_id
            end
            if l.index(:formulario)
              l[l.index(:formulario)] = :formulario_id
            end
            l += [ respuestafor_attributes: [
              :id,
              valorcampo_attributes: [
                :valor,
                :campo_id,
                :id 
              ] + 
              [:valor_ids => []]
            ]]
            return l
          end

          # Lista blanca de parametros
          def encuestausuario_params
            params.require(:encuestausuario).permit(lista_params)
          end

        end # included do

        class_methods do

        end

      end
    end
  end
end


