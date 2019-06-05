# encoding: UTF-8

class AmpliaNombreCampo < ActiveRecord::Migration[6.0]
  def change
    change_column :mr519_gen_campo, :nombre, :string, limit: 512
  end
end
