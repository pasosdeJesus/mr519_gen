class CreaFormulario < ActiveRecord::Migration[5.2]
  def change
    create_table :mr519_gen_formulario do |t|
      t.string :nombre, limit: 500, null: false
    end
  end
end
