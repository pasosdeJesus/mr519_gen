# encoding: UTF-8

class EnOpcioncsNombreAValor < ActiveRecord::Migration[5.2]

  def up
    Mr519Gen::Opcioncs.all.each do |o| 
      sec = ''
      if o.valor.nil?
        guardado = false
        begin 
          o.valor = ::Mr519Gen::ApplicationHelper.
            nombre_a_nombreinterno(o.nombre) + sec.to_s
          if !o.save
            puts o.errors.messages
            sec = sec == '' ? 1 : sec.to_i + 1
          else
            guardado = true
          end
        end while !guardado
      end
    end
  end

  def down
  end
end
