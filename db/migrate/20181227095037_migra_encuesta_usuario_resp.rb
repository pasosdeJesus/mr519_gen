class MigraEncuestaUsuarioResp < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      INSERT INTO mr519_gen_respuestafor (id, formulario_id, fechaini, 
        fechacambio) (SELECT id, formulario_id, COALESCE(fecha, fechainicio), 
        COALESCE(fecha, fechainicio) FROM
        mr519_gen_encuestausuario WHERE usuario_id IS NOT NULL AND
        formulario_id IS NOT NULL);
      UPDATE mr519_gen_encuestausuario SET respuestafor_id=formulario_id
        WHERE usuario_id IS NOT NULL AND formulario_id IS NOT NULL;
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM mr519_gen_respuestafor WHERE formulario_id in 
        (SELECT formulario_id FROM mr519_gen_encuestausuario WHERE
          usuario_id IS NOT NULL AND formulario_id IS NOT NULL);
    SQL
  end
end
