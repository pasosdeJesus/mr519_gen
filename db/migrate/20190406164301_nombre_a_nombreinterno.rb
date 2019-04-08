
class NombreANombreinterno < ActiveRecord::Migration[5.2]
  def up
    Mr519Gen::Campo.all.each do |c| 
      sec = ''
      guardado = false
      begin 
        c.nombreinterno=::Mr519Gen::ApplicationHelper.
          nombre_a_nombreinterno(c.nombre) + sec.to_s
        if !c.save
          sec = sec == '' ? 1 : sec.to_i + 1
        else
          guardado = true
        end
      end while !guardado
    end

    Mr519Gen::Formulario.all.each do |f| 
      sec = ''
      guardado = false
      begin 
        f.nombreinterno=::Mr519Gen::ApplicationHelper.
          nombre_a_nombreinterno(f.nombre) + sec.to_s
        if !f.save
          sec = sec == '' ? 1 : sec.to_i + 1
        else
          guardado = true
        end
      end while !guardado
    end
  end

  def down
  end
end
