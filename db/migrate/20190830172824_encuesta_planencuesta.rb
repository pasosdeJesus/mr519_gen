class EncuestaPlanencuesta < ActiveRecord::Migration[6.0]
  def up
    add_column :mr519_gen_encuestapersona, :planencuesta_id, :integer
    add_foreign_key :mr519_gen_encuestapersona, :mr519_gen_planencuesta,
      column: :planencuesta_id
    execute <<-SQL
      INSERT INTO mr519_gen_planencuesta (fechaini, fechafin, formulario_id, 
        created_at, updated_at)
         (SELECT DISTINCT fechainicio, fechafin, formulario_id, NOW(), NOW()
          FROM mr519_gen_encuestapersona) ;
      UPDATE mr519_gen_encuestapersona SET planencuesta_id=pe.id
        FROM mr519_gen_planencuesta AS pe WHERE 
        (pe.fechaini=fechainicio OR (pe.fechaini IS NULL AND fechainicio IS NULL) )
        AND (pe.fechafin=mr519_gen_encuestapersona.fechafin OR (pe.fechafin IS NULL AND mr519_gen_encuestapersona.fechafin IS NULL) )
        AND pe.formulario_id=mr519_gen_encuestapersona.formulario_id;
    SQL
    remove_column :mr519_gen_encuestapersona, :formulario_id
    remove_column :mr519_gen_encuestapersona, :fechainicio
    remove_column :mr519_gen_encuestapersona, :fechafin
  end
  def down
    add_column :mr519_gen_encuestapersona, :fechafin, :date
    add_column :mr519_gen_encuestapersona, :fechainicio, :date
    add_column :mr519_gen_encuestapersona, :formulario_id, :integer
    execute <<-SQL
      UPDATE mr519_gen_encuestapersona SET 
        formulario_id=pe.formulario_id,
        fechainicio=pe.fechaini,
        fechafin=pe.fechafin
        FROM mr519_gen_planencuesta AS pe WHERE 
        mr519_gen_encuestapersona.planencuesta_id=pe.id;
    SQL
    remove_column :mr519_gen_encuestapersona, :planencuesta_id, :integer
  end
end
