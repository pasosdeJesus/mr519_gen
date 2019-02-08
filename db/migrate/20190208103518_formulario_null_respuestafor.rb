class FormularioNullRespuestafor < ActiveRecord::Migration[5.2]
  def up
    change_column :mr519_gen_respuestafor, :formulario_id, :integer, 
      null: true
  end

  def down
    change_column :mr519_gen_respuestafor, :formulario_id, :integer, 
      null: false
  end
end
