class CreaCampo < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_campo do |t|
      t.string :nombre, limit: 128, null: false
      t.string :ayudauso, limit: 1024
      t.integer :tipo, null: false, default: 1
      t.boolean  :obligatorio
      t.integer :formulario_id, null: false
    end
    add_foreign_key :mr519_gen_campo, :mr519_gen_formulario,
      column: :formulario_id
  end
end
