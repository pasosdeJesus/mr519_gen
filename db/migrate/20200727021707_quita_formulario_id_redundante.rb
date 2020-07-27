class QuitaFormularioIdRedundante < ActiveRecord::Migration[6.0]
  def up 
    remove_column :mr519_gen_encuestausuario, :formulario_id
  end
  def down
    add_column :mr519_gen_encuestausuario, :formulario_id, :integer
  end
end
