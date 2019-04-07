class AgregaNombreinternoFormulario < ActiveRecord::Migration[5.2]
  def change
    add_column :mr519_gen_formulario, :nombreinterno, :string, limit: 60
    add_column :mr519_gen_campo, :nombreinterno, :string, limit: 60
  end
end
