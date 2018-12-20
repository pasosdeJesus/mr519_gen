class CreaEncuestausuarioValorcampo < ActiveRecord::Migration[5.2]
  def change
    create_join_table :mr519_gen_encuestausuario,
      :mr519_gen_valorcampo, {
      table_name: 'mr519_gen_encuestausuario_valorcampo'
    }
    add_foreign_key :mr519_gen_encuestausuario_valorcampo,
      :mr519_gen_encuestausuario
    add_foreign_key :mr519_gen_encuestausuario_valorcampo,
      :mr519_gen_valorcampo
    rename_column :mr519_gen_encuestausuario_valorcampo,
      :mr519_gen_encuestausuario_id, :encuestausuario_id
    rename_column :mr519_gen_encuestausuario_valorcampo,
      :mr519_gen_valorcampo_id, :valorcampo_id
  end
end
