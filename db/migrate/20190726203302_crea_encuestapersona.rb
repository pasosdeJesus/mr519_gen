class CreaEncuestapersona < ActiveRecord::Migration[6.0]
  def change
    create_table :mr519_gen_encuestapersona do |t|
      t.integer :persona_id
      t.integer :formulario_id
      t.date :fecha
      t.date :fechainicio, null: false
      t.date :fechafin
      t.string :adurl, limit: 32
      t.integer :respuestafor_id
    end
    add_foreign_key :mr519_gen_encuestapersona, :sip_persona, 
      column: :persona_id
    add_foreign_key :mr519_gen_encuestapersona, :mr519_gen_formulario,
      column: :formulario_id
    add_foreign_key :mr519_gen_encuestapersona, :mr519_gen_respuestafor, 
      column: :respuestafor_id
    add_index :mr519_gen_encuestapersona, :adurl, unique: true
  end
end
