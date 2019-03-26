class ValorJson < ActiveRecord::Migration[5.2]
  def change
    add_column :mr519_gen_valorcampo, :valorjson, :json
  end
end
