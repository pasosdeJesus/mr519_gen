#!/bin/sh
# Inicializa base de prueba, corre 2 pruebas de regresión (test y test:system) 
# y finalmente genera reporte de cobertura mezclando resultados en 
# directorio coverage y publicandolo HTML en public/mimotor/cobertura

rutaap="./"
if (test -f test/dummy/config/application.rb)  then {
  rutaap="test/dummy/"
  . test/dummy/.env
} else {
  . ./.env
} fi;

echo "== Prepara"
(cd $rutaap; RAILS_ENV=test bin/rails db:drop db:setup db:seed msip:indices)
if (test "$?" != "0") then {
  echo "No puede preparse base de prueba";
  exit 1;
} fi;

echo "== Pruebas de regresión unitarias"
mkdir -p cobertura-unitarias/
rm -rf cobertura-unitarias/{*,.*}
CONFIG_HOSTS=www.example.com bin/rails test

echo "== Pruebas de regresión al sistema"
if (test -f "test/dummy/config/application.rb") then {
  mkdir -p test/dummy/cobertura-sistema/
  rm -rf test/dummy/cobertura-sistema/{*,.*}
  (cd test/dummy; CONFIG_HOSTS=127.0.0.1 bin/rails msip:stimulus_motores test:system)
} else {
  mkdir -p cobertura-sistema/
  rm -rf cobertura-sistema/{*,.*}
  CONFIG_HOSTS=127.0.0.1 bin/rails msip:stimulus_motores test:system
} fi;

echo "== Unificando resultados de pruebas en directorio clásico coverage"
mkdir -p coverage/
rm -rf coverage/{*,.*}
bin/rails app:msip:reporteregresion

echo "== Copiando resultados para hacerlos visibles en el web en ruta cobertura"
# Copiar resultados para hacerlos visibles en web
mkdir -p test/dummy/public/msip/cobertura/
cp -rf coverage/* test/dummy/public/msip/cobertura/
cp -rf coverage/assets/* test/dummy/public/msip/assets/
#!/bin/sh
# Inicializa base de prueba, corre 2 pruebas de regresión (test y test:system) 
# y finalmente genera reporte de cobertura mezclando resultados en 
# directorio coverage y publicandolo HTML en public/mimotor/cobertura


echo "== Pruebas de regresión unitarias"
mkdir -p cobertura-unitarias/
rm -rf cobertura-unitarias/{*,.*}
CONFIG_HOSTS=www.example.com bin/rails test

echo "== Pruebas de regresión al sistema"
if (test -f "test/dummy/config/application.rb") then {
  mkdir -p test/dummy/cobertura-sistema/
  rm -rf test/dummy/cobertura-sistema/{*,.*}
  (cd test/dummy; CONFIG_HOSTS=127.0.0.1 bin/rails msip:stimulus_motores test:system)
} else {
  mkdir -p cobertura-sistema/
  rm -rf cobertura-sistema/{*,.*}
  CONFIG_HOSTS=127.0.0.1 bin/rails msip:stimulus_motores test:system
} fi;

echo "== Unificando resultados de pruebas en directorio clásico coverage"
mkdir -p coverage/
rm -rf coverage/{*,.*}
bin/rails app:msip:reporteregresion

echo "== Copiando resultados para hacerlos visibles en el web en ruta cobertura"
# Copiar resultados para hacerlos visibles en web
mkdir -p test/dummy/public/${RUTA_RELATIVA}/cobertura/
cp -rf coverage/* test/dummy/public/${RUTA_RELATIVA}/cobertura/
cp -rf coverage/assets/* test/dummy/public/${RUTA_RELATIVA}/assets/
