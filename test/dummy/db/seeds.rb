# frozen_string_literal: true

conexion = ActiveRecord::Base.connection

Msip.carga_semillas_sql(conexion, "msip", :datos)

conexion.execute("INSERT INTO public.usuario
 (nusuario, email, encrypted_password, password,
 fechacreacion, created_at, updated_at, rol)
 VALUES ('mr519', 'msip@localhost',
 '$2a$10$.o1/iAq6Cu9d3r5eWnHUTuPim9BJnGlvGyBS3gzVCVgk592o74jH2',
 '', '2014-08-14', '2014-08-14', '2014-08-14', 1);")
