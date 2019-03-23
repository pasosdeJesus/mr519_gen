class AgregaOpcionescs < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_opcioncs do |t|
      t.integer :campo_id, null: false
      t.string  :nombre, null: false, limit: 1024
      t.string  :valor, null: false, limit: 1024
    end
    add_foreign_key :mr519_gen_opcioncs, :mr519_gen_campo, column: :campo_id
  end
end
