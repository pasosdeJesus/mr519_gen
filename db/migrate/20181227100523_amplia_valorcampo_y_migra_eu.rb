class AmpliaValorcampoYMigraEu < ActiveRecord::Migration[5.2]
  def up
    add_column :mr519_gen_valorcampo, :respuestafor_id, :integer
    add_foreign_key :mr519_gen_valorcampo, :mr519_gen_respuestafor, column: :respuestafor_id
    execute <<-SQL
      UPDATE mr519_gen_valorcampo SET
        respuestafor_id=formulario_id FROM mr519_gen_encuestausuario_valorcampo
        JOIN mr519_gen_encuestausuario ON
        encuestausuario_id=mr519_gen_encuestausuario.id;
    SQL
    change_column :mr519_gen_valorcampo, :respuestafor_id, :integer, null: false
  end
  def down
    remove_column :mr519_gen_valorcampo, :respuestafor_id
  end
end
