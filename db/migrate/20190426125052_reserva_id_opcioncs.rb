class ReservaIdOpcioncs < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      SELECT setval('mr519_gen_opcioncs_id_seq', 1000);
    SQL
  end
end
