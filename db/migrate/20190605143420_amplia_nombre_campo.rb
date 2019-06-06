# encoding: UTF-8

class AmpliaNombreCampo < ActiveRecord::Migration[6.0]
  def up
    change_column :mr519_gen_campo, :nombre, :string, limit: 512
  end
  def down
    change_column :mr519_gen_campo, :nombre, :string, limit: 128
  end
end
