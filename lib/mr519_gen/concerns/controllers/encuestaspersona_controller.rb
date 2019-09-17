# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Controllers
      module EncuestaspersonaController
        extend ActiveSupport::Concern

        included do

          before_action :set_encuestapersona, 
            only: [:show, :edit, :update, :destroy]
          #load_and_authorize_resource class: Mr519Gen::Encuestapersona
          # Mejor metodo a metodo y podrían ser solo parte de los registros

          def clase
            "Mr519Gen::Encuestapersona"
          end

          def genclase
            return 'F'
          end

          def filtrar_ca(reg)
            if cannot?(:manage, Mr519Gen::Encuestapersona)
              reg = nil
            end
            return reg
          end

          def atributos_index
            r = [ :id ]
            if can?(:manage, Mr519Gen::Encuestapersona)
              r << :persona
              r << :formulariodec
              r << :fechaini_localizada
              r << :fechafin_localizada
              r << :fechacambio_localizada
              r << :adurl
            end
            r += [
                   :respuestafor
            ]
          end

          def atributos_form
            r = atributos_show - [:id]
            if cannot?(:manage, Mr519Gen::Encuestapersona)
              r = r - [:fechainicio_localizada, 
                       :fechafin_localizada]
            end
            return r
          end

          def atributos_show
            atributos_index
          end

          def index_reordenar(c)
            c = c.reorder('mr519_gen_encuestapersona.fecha DESC')
            return c
          end

          # GET /encuestaspersona/new
          def new
            @registro = @encuestapersona = Encuestapersona.new
            @registro.fechainicio = Date.today
            @registro.respuestafor = Respuestafor.new
            @registro.respuestafor.fechaini = Date.today
            @registro.respuestafor.fechacambio = Date.today
            @registro.persona = Sip::Persona.all.take
            #@registro.regenerate_adurl
            @registro.fecha = Date.today
            @registro.save!(validate: false)
            redirect_to mr519_gen.edit_encuestapersona_path(@registro)
          end


          def edit_mr519_gen
            @registro = Mr519Gen::Encuestapersona.find(params[:id])
            authorize! :edit, @registro
            ::Mr519Gen::ApplicationHelper::asegura_camposdinamicos(
              @registro, current_usuario.id)
            @registro.save!(validate: false)
          end

          # GET /encuestaspersona/1/edit
          def edit
            edit_mr519_gen
            render layout: 'application'
          end

          def externa
            adurl = params[:adurl]
            if Mr519Gen::Encuestapersona.where(adurl: adurl).count != 1
              raise CanCan::AccessDenied.new("Not authorized!", :read, 
                                            Mr519Gen::Encuestapersona)
            end
            @registro = Mr519Gen::Encuestapersona.where(adurl: adurl).take
            ::Mr519Gen::ApplicationHelper::asegura_camposdinamicos(@registro)
            @registro.save!(validate: false)
            render action: 'externa'#, layout: 'nil
          end

          def update
            params[:encuestapersona][:fechacambio_localizada] = 
              Sip::FormatoFechaHelper::fecha_estandar_local(Date.today)
            @encuestapersona = @registro = Mr519Gen::Encuestapersona.find(params[:id])
            authorize! :update, @registro
            if @registro.update(encuestapersona_params) 
              if current_usuario.nil? || URI(request.referer).path.
                starts_with?('/encuestaexterna/')
                render action: 'gracias'
              else
                redirect_to modelo_path(@registro), 
                  notice: 'Encuesta actualizada'
              end  
            else
              render action: 'edit'#, layout: 'application'
            end
          end

          def resultados
            if !params || !params[:formulario_id]
              render inline: 'Falta parámetro formulario_id'
              return
            end
            fid = Encuestapersona.connection.
              quote_string(params[:formulario_id]).to_i
            @registros = Encuestapersona.joins(:respuestafor).
              where("mr519_gen_respuestafor.formulario_id" => fid)
            if @registros.count == 0
              render inline: 
                "No hay encuestas respondidas para formulario #{fid}"
              return
            end
            @titulo = "Resultados de encuesta: " +
              @registros[0].respuestafor.formulario.nombre
            @personas = @registros.map(&:persona)
            @consolidado = []
            @registros[0].respuestafor.formulario.campo.order(:id).each do |c|
              case c.tipo 
              when Mr519Gen::ApplicationHelper::TEXTO, 
                Mr519Gen::ApplicationHelper::TEXTOLARGO
                cons = Mr519Gen::Valorcampo.where(campo_id: c.id).map(&:valor).
                  join(".<hr>")
                cons = cons.html_safe
              when Mr519Gen::ApplicationHelper::ENTERO,
                Mr519Gen::ApplicationHelper::FLOTANTE
                cons = Mr519Gen::Valorcampo.where(campo_id: c.id).
                  average("CASE 
                             WHEN valor = '' THEN 0 
                             ELSE CAST(valor AS NUMERIC) 
                           END")
              when Mr519Gen::ApplicationHelper::BOOLEANO
                si = Mr519Gen::Valorcampo.where(campo_id: c.id).
                  where(valor: 't').count
                no = Mr519Gen::Valorcampo.where(campo_id: c.id).
                  where("valor <> 't'").count
                cons = "Si: #{si}.  No: #{no}"  
              else
                puts "Tipo desconocido"
                cons = "Tipo desconocido"
              end
              @consolidado << {pregunta: c.nombre, consolidado: cons}
            end
            render 'resultados', layot: 'application'
          end 
          

          private

          def set_encuestapersona
            @registro = @encuestapersona = Encuestapersona.find(
              Encuestapersona.connection.quote_string(params[:id]).to_i
            )
          end

          def lista_params
            l = atributos_form
            if l.index(:persona)
              l[l.index(:persona)] = :persona_id
            end
            if l.index(:formulariodec)
              l[l.index(:formulariodec)] = :formulario_id
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
          def encuestapersona_params
            params.require(:encuestapersona).permit(lista_params)
          end

        end # included do

        class_methods do

        end

      end
    end
  end
end


