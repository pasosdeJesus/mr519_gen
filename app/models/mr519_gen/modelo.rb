# encoding: UTF-8

# Extiende Sip::Modelo para facilitar presentar
# información de formularios
module Mr519Gen
  module Modelo 
    extend ActiveSupport::Concern

    included do
      include Sip::Modelo

      def presenta_gen_mr519(atr)
        if atr.to_s.include?(".")
          pa = atr.split('.')
          f = Mr519Gen::Formulario.
            where(nombreinterno: pa[0])
          if f.count == 1
            fr = f.take
            if self.respuestafor && 
              self.respuestafor.where(
                formulario_id:  fr.id).count == 1
              rf = self.respuestafor.where(
                formulario_id: fr.id).take
              ca = fr.campo.where(nombreinterno: pa[1])
              if ca.count == 1
                vc = rf.valorcampo.where(
                  campo_id: ca.take.id)
                if vc.count == 1
                  return vc.take.presenta_valor(false)
                else
                  return "Hay más de un valor para campo '#{pa[1]}' de formulario '#{pa[0]}'"
                end
              else
                return "No hay campo '#{pa[1]}' en formulario '#{pa[0]}'"
              end
            else
              puts "No hay respuesta para formulario '#{pa[0]}"
              return ''
            end
          elsif f.count == 0
            return "No hay formulario '#{pa[0]}'"
          else
            return "Varios formularios '#{pa[0]}'"
          end
          
        else
          presenta_gen_sip(atr)
        end
      end

      def presenta_gen(atr)
        presenta_gen_mr519(atr)
      end

    end
  end
end
