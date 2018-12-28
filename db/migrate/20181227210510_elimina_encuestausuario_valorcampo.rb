class EliminaEncuestausuarioValorcampo < ActiveRecord::Migration[5.2]
  def up
    drop_table :mr519_gen_encuestausuario_valorcampo
  end
  def downs
  end
end
