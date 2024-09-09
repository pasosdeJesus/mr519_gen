# frozen_string_literal: true

module Mr519Gen
  # Extiende Msip::Modelo para facilitar presentar
  # información de formularios
  module Modelo
    extend ActiveSupport::Concern

    included do
      include Msip::Modelo

      def presenta_gen_mr519(atr)
        if atr.to_s.include?(".")
          pa = atr.split(".")
          f = Mr519Gen::Formulario
            .where(nombreinterno: pa[0])
          if f.count == 1
            fr = f.take
            if respuestafor &&
                respuestafor.where(
                  formulario_id: fr.id,
                ).count == 1
              rf = respuestafor.find_by(
                formulario_id: fr.id,
              )
              ca = fr.campo.where(nombreinterno: pa[1])
              return "No hay campo '#{pa[1]}' en formulario '#{pa[0]}'" unless ca.count == 1

              vc = rf.valorcampo.where(
                campo_id: ca.take.id,
              )
              if vc.count == 1
                vc.take.presenta_valor(false)
              elsif vc.count == 0
                ""
              else
                "Hay más de un valor para campo '#{pa[1]}' de formulario '#{pa[0]}'"
              end

            else
              puts "No hay respuesta para formulario '#{pa[0]}"
              ""
            end
          elsif f.count == 0
            "No hay formulario '#{pa[0]}'"
          else
            "Varios formularios '#{pa[0]}'"
          end

        else
          presenta_gen_msip(atr)
        end
      end

      def presenta_gen(atr)
        presenta_gen_mr519(atr)
      end
    end
  end
end
