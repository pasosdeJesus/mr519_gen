class CreaValorcampo < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_valorcampo do |t|
      t.integer :campo_id, null: false
      t.string :valor, limit: 5000
    end
    add_foreign_key :mr519_gen_valorcampo, 
      :mr519_gen_campo, column: :campo_id
  end
end
