# encoding: UTF-8

class AgregaFilaCampo < ActiveRecord::Migration[6.0]
  def change
    add_column :mr519_gen_campo, :fila, :integer
    add_column :mr519_gen_campo, :columna, :integer
    add_column :mr519_gen_campo, :ancho, :integer
  end
end
