class AgregaTablabasicaCampo < ActiveRecord::Migration[6.0]
  def change
    add_column :mr519_gen_campo, :tablabasica, :string, limit: 32
  end
end
