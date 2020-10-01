class CreaPlanencuesta < ActiveRecord::Migration[6.0]
  def up
    if table_exists?(:planencuesta)
      rename_table :planencuesta, :mr519_gen_planencuesta
    else
      create_table :mr519_gen_planencuesta do |t|
        t.date      :fechaini
        t.date      :fechafin
        t.integer   :formulario_id
        t.integer   :plantillacorreoinv_id
        t.string    :adurl, limit: 32
        t.timestamp :created_at, null: false
        t.timestamp :updated_at, null: false
      end
    end
  end

  def down
    drop_table :mr519_gen_planencuesta
  end
end
