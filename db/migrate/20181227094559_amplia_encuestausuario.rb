class AmpliaEncuestausuario < ActiveRecord::Migration[5.2]
  def change
    add_column :mr519_gen_encuestausuario, :respuestafor_id, :integer
    add_foreign_key :mr519_gen_encuestausuario,  :mr519_gen_respuestafor,
      column: :respuestafor_id
  end
end
