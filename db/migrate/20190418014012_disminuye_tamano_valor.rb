class DisminuyeTamanoValor < ActiveRecord::Migration[5.2]
  def up
    change_column :mr519_gen_opcioncs, :valor, :string,
      limit: 60
  end
  def down
    change_column :mr519_gen_opcioncs, :valor, :string,
      limit: 1024
  end
end
