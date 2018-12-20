class CreaEncuestausuario < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_encuestausuario do |t|
      t.integer :usuario_id, null: false
      t.integer :formulario_id
      t.date :fecha
      t.date :fechainicio, null: false
      t.date :fechafin
    end
    add_foreign_key :mr519_gen_encuestausuario, :usuario
    add_foreign_key :mr519_gen_encuestausuario, :mr519_gen_formulario,
      column: :formulario_id
  end
end
