class Reserva < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      SELECT setval('mr519_gen_campo_id_seq', 1000);
      SELECT setval('mr519_gen_formulario_id_seq', 100);
      SELECT setval('mr519_gen_respuestafor_id_seq', 200);
      SELECT setval('mr519_gen_encuestausuario_id_seq', 200);
      SELECT setval('mr519_gen_valorcampo_id_seq', 1000);
    SQL
  end
  def down
  end
end
