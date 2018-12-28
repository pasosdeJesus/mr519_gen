# encoding: utf-8

class CreaRespuestafor < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_respuestafor do |t|
      t.integer :formulario_id, null: false
      t.date  :fechaini, null: false
      t.date  :fechacambio, null: false
    end
    add_foreign_key :mr519_gen_respuestafor, :mr519_gen_formulario, column: :formulario_id
  end
end
