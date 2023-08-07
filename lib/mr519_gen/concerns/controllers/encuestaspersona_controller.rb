# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Controllers
      module EncuestaspersonaController
        extend ActiveSupport::Concern

        included do
          def clase
            "Mr519Gen::Encuestapersona"
          end

          def genclase
            "F"
          end

          def filtrar_ca(reg)
            reg = nil if cannot?(:manage, Mr519Gen::Encuestapersona)
            reg
          end

          def atributos_index
            r = [:id]
            if can?(:manage, Mr519Gen::Encuestapersona)
              r << :persona
              r << :planencuesta_id
              r << :fechacambio_localizada
              r << :adurl
            end
            r += [
              :respuestafor,
            ]
          end

          def atributos_form
            atributos_show - [:id]
          end

          def atributos_show
            atributos_index
          end

          def index_reordenar(c)
            c = c.reorder("mr519_gen_encuestapersona.fecha DESC") if c
            c
          end

          # GET /encuestaspersona/new
          def new
            authorize!(:manage, Mr519Gen::Encuestapersona)
            @registro = @encuestapersona = Encuestapersona.new
            @registro.respuestafor = Respuestafor.new
            @registro.respuestafor.fechaini = Date.today
            @registro.respuestafor.fechacambio = Date.today
            @registro.persona = Msip::Persona.all.take
            # @registro.regenerate_adurl
            @registro.fecha = Date.today
            @registro.save!(validate: false)
            redirect_to(mr519_gen.edit_encuestapersona_path(@registro))
          end

          def self.asegura_camposdinamicos(encuesta, current_usuario_id)
            if !encuesta.respuestafor_id
              encuesta.respuestafor = Mr519Gen::Respuestafor.create(
                {
                  formulario_id: encuesta.planencuesta.formulario_id,
                  fechaini: Date.today,
                  fechacambio: Date.today,
                },
              )
            elsif !encuesta.respuestafor.formulario_id &&
                encuesta.planencuesta &&
                encuesta.planencuesta.formulario_id
              encuesta.respuestafor.formulario_id =
                encuesta.planencuesta.formulario_id
              encuesta.save!(validate: false)
            end
            ::Mr519Gen::ApplicationHelper.asegura_camposdinamicos(
              encuesta, current_usuario_id
            )
            encuesta.save!(validate: false)
          end

          def edit_mr519_gen
            @registro = Mr519Gen::Encuestapersona.find(params[:id])
            authorize!(:edit, @registro)
            self.class.asegura_camposdinamicos(
              @registro, current_usuario.id
            )
            return unless @registro.adurl.nil? || @registro.adurl == ""

            @registro.regenerate_adurl
            @registro.save
          end

          # GET /encuestaspersona/1/edit
          def edit
            edit_mr519_gen
            render(layout: "application")
          end

          def externa
            adurl = params[:adurl]
            if Mr519Gen::Encuestapersona.where(adurl: adurl).count != 1
              raise CanCan::AccessDenied.new(
                "Not authorized!",
                :read,
                Mr519Gen::Encuestapersona,
              )
            end
            @registro = Mr519Gen::Encuestapersona.where(adurl: adurl)
              .take
            self.class.asegura_camposdinamicos(
              @registro, current_usuario ? current_usuario.id : nil
            )
            render(action: "externa", layout: "mr519_gen/externo")
          end

          def update
            params[:encuestapersona][:fechacambio_localizada] =
              Msip::FormatoFechaHelper.fecha_estandar_local(Date.today)
            @encuestapersona = @registro =
              Mr519Gen::Encuestapersona.find(params[:id])
            if @registro.update(encuestapersona_params)
              if current_usuario.nil? || (request && request.referer &&
                  URI(request.referer).path.starts_with?("/encuestaexterna/"))
                render(action: "gracias", layout: "externo")
              else
                # Con usuarios autenticados si verificamos posibilidad
                # de actualizar
                authorize!(:update, @registro)
                redirect_to(
                  modelo_path(@registro),
                  notice: "Encuesta actualizada",
                )
              end
            else
              render(action: "edit") # , layout: 'application'
            end
          end

          def resultados
            authorize!(:manage, Mr519Gen::Encuestapersona)
            if !params || !params[:formulario_id]
              render(inline: "Falta parámetro formulario_id")
              return
            end
            fid = Encuestapersona.connection
              .quote_string(params[:formulario_id]).to_i
            @registros = Encuestapersona.joins(:respuestafor)
              .where("mr519_gen_respuestafor.formulario_id" => fid)
            if @registros.count == 0
              render(inline:
                "No hay encuestas respondidas para formulario #{fid}")
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
                cons = Mr519Gen::Valorcampo.where(campo_id: c.id).map(&:valor) +
                  ".<hr>".html_safe
              when Mr519Gen::ApplicationHelper::ENTERO,
                Mr519Gen::ApplicationHelper::FLOTANTE
                cons = Mr519Gen::Valorcampo.where(campo_id: c.id)
                  .average("CASE
                             WHEN valor = '' THEN 0
                             ELSE CAST(valor AS NUMERIC)
                           END")
              when Mr519Gen::ApplicationHelper::BOOLEANO
                si = Mr519Gen::Valorcampo.where(campo_id: c.id)
                  .where(valor: "t").count
                no = Mr519Gen::Valorcampo.where(campo_id: c.id)
                  .where("valor <> 't'").count
                cons = "Si: #{si}.  No: #{no}"
              else
                puts "Tipo desconocido"
                cons = "Tipo desconocido"
              end
              @consolidado << { pregunta: c.nombre, consolidado: cons }
            end
            render("resultados", layout: "application")
          end

          def show
            if can?(:read, Mr519Gen::Encuestapersona)
              render(action: :show, layout: "application")
            else
              redirect_to(main_app.root_path)
            end
          end

          private

          def set_encuestapersona
            @registro = @encuestapersona = Encuestapersona.find(
              Encuestapersona.connection.quote_string(params[:id]).to_i,
            )
          end

          def lista_params_mr519_gen
            l = atributos_form
            l[l.index(:persona)] = :persona_id if l.index(:persona)
            l[l.index(:formulariodec)] = :formulario_id if l.index(:formulariodec)
            l += [respuestafor_attributes: [
              :id,
              {
                valorcampo_attributes: [
                  :valor,
                  :campo_id,
                  :id,
                ] +
                  [valor_ids: []],
              },
            ]]
            l
          end

          def lista_params
            lista_params_mr519_gen
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
