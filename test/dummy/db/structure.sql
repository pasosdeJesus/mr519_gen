SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.es_co_utf_8 (provider = libc, locale = 'es_CO.UTF-8');


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: completa_obs(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.completa_obs(obs character varying, nuevaobs character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN CASE WHEN obs IS NULL THEN nuevaobs
          WHEN obs='' THEN nuevaobs
          WHEN RIGHT(obs, 1)='.' THEN obs || ' ' || nuevaobs
          ELSE obs || '. ' || nuevaobs
        END;
      END; $$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT public.unaccent('public.unaccent', $1)  
      $_$;


--
-- Name: msip_agregar_o_remplazar_familiar_inverso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_agregar_o_remplazar_familiar_inverso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        num2 INTEGER;
        rinv CHAR(2);
        rexistente CHAR(2);
      BEGIN
        ASSERT(TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
        RAISE NOTICE 'Insertando o actualizando en msip_persona_trelacion';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.persona1 = %', NEW.persona1;
        RAISE NOTICE 'NEW.persona2 = %', NEW.persona2;
        RAISE NOTICE 'NEW.trelacion_id = %', NEW.trelacion_id;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        SELECT COUNT(*) INTO num2 FROM msip_persona_trelacion
          WHERE persona1 = NEW.persona2 AND persona2=NEW.persona1;
        RAISE NOTICE 'num2 = %', num2;
        ASSERT(num2 < 2);
        SELECT inverso INTO rinv FROM msip_trelacion 
          WHERE id = NEW.trelacion_id;
        RAISE NOTICE 'rinv = %', rinv;
        ASSERT(rinv IS NOT NULL);
        CASE num2
          WHEN 0 THEN
            INSERT INTO msip_persona_trelacion 
            (persona1, persona2, trelacion_id, observaciones, created_at, updated_at)
            VALUES (NEW.persona2, NEW.persona1, rinv, 'Inverso agregado automaticamente', NOW(), NOW());
          ELSE -- num2 = 1
            SELECT trelacion_id INTO rexistente FROM msip_persona_trelacion
              WHERE persona1=NEW.persona2 AND persona2=NEW.persona1;
            RAISE NOTICE 'rexistente = %', rexistente;
            IF rinv <> rexistente THEN
              UPDATE msip_persona_trelacion 
                SET trelacion_id = rinv,
                 observaciones = 'Inverso cambiado automaticamente (era ' ||
                   rexistente || '). ' || COALESCE(observaciones, ''),
                 updated_at = NOW()
                WHERE persona1=NEW.persona2 AND persona2=NEW.persona1;
            END IF;
        END CASE;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_edad_de_fechanac_fecharef(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_edad_de_fechanac_fecharef(anionac integer, mesnac integer, dianac integer, anioref integer, mesref integer, diaref integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
            SELECT CASE 
              WHEN anionac IS NULL THEN NULL
              WHEN anioref IS NULL THEN NULL
              WHEN anioref < anionac THEN -1
              WHEN mesnac IS NOT NULL AND mesnac > 0 
                AND mesref IS NOT NULL AND mesref > 0 
                AND mesnac >= mesref THEN
                CASE 
                  WHEN mesnac > mesref OR (dianac IS NOT NULL 
                    AND dianac > 0 AND diaref IS NOT NULL 
                    AND diaref > 0 AND dianac > diaref) THEN 
                    anioref-anionac-1
                  ELSE 
                    anioref-anionac
                END
              ELSE
                anioref-anionac
            END 
          $$;


--
-- Name: msip_eliminar_familiar_inverso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_eliminar_familiar_inverso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        num2 INTEGER;
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando inverso de msip_persona_trelacion';
        SELECT COUNT(*) INTO num2 FROM msip_persona_trelacion
          WHERE persona1 = OLD.persona2 AND persona2=OLD.persona1;
        RAISE NOTICE 'num2 = %', num2;
        ASSERT(num2 < 2);
        IF num2 = 1 THEN
            DELETE FROM msip_persona_trelacion 
            WHERE persona1 = OLD.persona2 AND persona2 = OLD.persona1;
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_nombre_vereda(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_nombre_vereda() RETURNS character varying
    LANGUAGE sql
    AS $$
        SELECT 'Vereda '
      $$;


--
-- Name: msip_ubicacionpre_actualiza_nombre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_actualiza_nombre() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        temp TEXT[];
        nompais TEXT;
        nomdep TEXT;
        nommun TEXT;
        nomver TEXT;
        nomcp TEXT;
      BEGIN
        RAISE NOTICE 'Al comienzo new.nombre=%', new.nombre;
        nompais := COALESCE((SELECT nombre FROM public.msip_pais WHERE id=new.pais_id LIMIT 1), '');
        RAISE NOTICE 'nompais=%', nompais;
        nomdep := COALESCE((SELECT nombre FROM public.msip_departamento WHERE id=new.departamento_id LIMIT 1), '');
        RAISE NOTICE 'nomdep=%', nomdep;
        nommun := COALESCE((SELECT nombre FROM public.msip_municipio WHERE id=new.municipio_id LIMIT 1), '');
        RAISE NOTICE 'nommun=%', nommun;
        nomcp := COALESCE((SELECT nombre FROM public.msip_centropoblado WHERE id=new.centropoblado_id LIMIT 1), '');
        RAISE NOTICE 'nomcp=%', nomcp;
        nomver := COALESCE((SELECT nombre FROM public.msip_vereda WHERE id=new.vereda_id LIMIT 1), '');
        RAISE NOTICE 'nomver=%', nomver;

        temp = public.msip_ubicacionpre_nomenclatura(nompais,
          nomdep, nommun, nomver, nomcp, new.lugar, new.sitio);
        new.nombre := temp[1];
        RAISE NOTICE 'new.nombre=%', new.nombre;
        new.nombre_sin_pais := temp[2];
        RAISE NOTICE 'new.nombre_sin_pais=%', new.nombre_sin_pais;
        RETURN new;
      END
      $$;


--
-- Name: msip_ubicacionpre_antes_de_eliminar_centropoblado(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_centropoblado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando centropoblado';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'OLD.id = %', OLD.id;
        RAISE NOTICE 'OLD.nombre = %', OLD.nombre;

        DELETE FROM public.msip_ubicacionpre WHERE 
          municipio_id=OLD.municipio_id
          AND centropoblado_id=OLD.id
          AND vereda_id IS NULL
          AND lugar IS NULL;
        RETURN OLD;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_antes_de_eliminar_departamento(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_departamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando departamento';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'OLD.id = %', OLD.id;
        RAISE NOTICE 'OLD.nombre = %', OLD.nombre;

        DELETE FROM public.msip_ubicacionpre WHERE pais_id=OLD.pais_id 
          AND departamento_id=OLD.id
          AND municipio_id IS NULL
          AND centropoblado_id IS NULL
          AND vereda_id IS NULL
          AND lugar IS NULL;
        RETURN OLD;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_antes_de_eliminar_municipio(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_municipio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando municipio';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'OLD.id = %', OLD.id;
        RAISE NOTICE 'OLD.nombre = %', OLD.nombre;

        DELETE FROM public.msip_ubicacionpre WHERE 
          departamento_id=OLD.departamento_id
          AND municipio_id=OLD.id
          AND centropoblado_id IS NULL
          AND vereda_id IS NULL
          AND lugar IS NULL;
        RETURN OLD;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_antes_de_eliminar_pais(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_pais() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando país';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'OLD.id = %', OLD.id;
        RAISE NOTICE 'OLD.nombre = %', OLD.nombre;

        -- Pero no elimina en cascada
        DELETE FROM public.msip_ubicacionpre WHERE pais_id=OLD.id
          AND departamento_id IS NULL 
          AND municipio_id IS NULL
          AND centropoblado_id IS NULL
          AND vereda_id IS NULL
          AND lugar IS NULL
          AND sitio IS NULL;

        RETURN OLD;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_antes_de_eliminar_vereda(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_vereda() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando vereda';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'OLD.id = %', OLD.id;
        RAISE NOTICE 'OLD.nombre = %', OLD.nombre;

        DELETE FROM public.msip_ubicacionpre WHERE 
          municipio_id=OLD.municipio_id
          AND vereda_id=OLD.id
          AND centropoblado_id IS NULL
          AND lugar IS NULL;
        RETURN OLD;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_dpa_nomenclatura(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_dpa_nomenclatura(pais character varying, departamento character varying, municipio character varying, vereda character varying, centropoblado character varying) RETURNS text[]
    LANGUAGE sql
    AS $$
        SELECT CASE
        WHEN pais IS NULL OR TRIM(pais) = '' THEN
          array['', '']
        WHEN departamento IS NULL OR TRIM(departamento) = '' THEN
          array[TRIM(pais), '']
        WHEN municipio IS NULL OR TRIM(municipio) = '' THEN
          array[TRIM(departamento) || ' / ' || TRIM(pais), TRIM(departamento)]
        WHEN (vereda IS NULL OR TRIM(vereda) = '') AND
        (centropoblado IS NULL OR TRIM(centropoblado) = '') THEN
          array[
            TRIM(municipio) || ' / ' || TRIM(departamento) || ' / ' || 
              TRIM(pais),
            TRIM(municipio) || ' / ' || TRIM(departamento) ]
        WHEN (vereda IS NOT NULL AND TRIM(vereda)<>'') THEN
          array[
            public.msip_nombre_vereda() || TRIM(vereda) || ' / ' ||
              TRIM(municipio) || ' / ' || TRIM(departamento) || ' / ' || 
              TRIM(pais),
            public.msip_nombre_vereda() || TRIM(vereda) || ' / ' ||
              TRIM(municipio) || ' / ' || TRIM(departamento) ]
        ELSE
          array[
            TRIM(centropoblado) || ' / ' ||
              TRIM(municipio) || ' / ' || TRIM(departamento) || ' / ' || 
              TRIM(pais),
            TRIM(centropoblado) || ' / ' ||
            TRIM(municipio) || ' / ' || TRIM(departamento) ]
         END
      $$;


--
-- Name: msip_ubicacionpre_id_rtablabasica(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_id_rtablabasica() RETURNS integer
    LANGUAGE sql
    AS $$
        SELECT max(id+1) FROM msip_ubicacionpre WHERE 
          (id+1) NOT IN (SELECT id FROM msip_ubicacionpre) AND 
          id<10000000
      $$;


--
-- Name: msip_ubicacionpre_nomenclatura(character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_nomenclatura(pais character varying, departamento character varying, municipio character varying, vereda character varying, centropoblado character varying, lugar character varying, sitio character varying) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
      BEGIN
        dpa := public.msip_ubicacionpre_dpa_nomenclatura(pais, departamento,
            municipio, vereda, centropoblado);
        --RAISE NOTICE 'dpa[1]=%', dpa[1];
        --RAISE NOTICE 'dpa[2]=%', dpa[2];
        IF (lugar IS NULL OR lugar = '') THEN
          return dpa;
        ELSEIF (sitio IS NULL OR sitio= '') THEN
          return array[
              lugar || ' / ' || dpa[1],
              lugar || ' / ' || dpa[2]
            ];
        ELSE
          return array[
              sitio || ' / ' || lugar || ' / ' || dpa[1],
              sitio || ' / ' || lugar || ' / ' || dpa[2] 
          ];
        END IF;
      END
      $$;


--
-- Name: msip_ubicacionpre_tras_actualizar_centropoblado(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_actualizar_centropoblado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        mi_departamento_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
        nommunicipio TEXT;
      BEGIN
        ASSERT(TG_OP = 'UPDATE');
        RAISE NOTICE 'Actualizando centropoblado';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
        RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
        RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        mi_departamento_id := (SELECT departamento_id 
          FROM public.msip_municipio
          WHERE id=NEW.municipio_id LIMIT 1);
        mi_pais_id := (SELECT pais_id FROM public.msip_departamento
          WHERE id=mi_departamento_id LIMIT 1);
        nompais := (SELECT nombre FROM public.msip_pais 
          WHERE id=mi_pais_id LIMIT 1);
        nomdepartamento := (SELECT nombre FROM public.msip_departamento
          WHERE id=mi_departamento_id LIMIT 1);
        nommunicipio := (SELECT nombre FROM public.msip_municipio
          WHERE id=NEW.municipio_id LIMIT 1);

        dpa := public.msip_ubicacionpre_dpa_nomenclatura(
          nompais, nomdepartamento, nommunicipio, '', NEW.nombre
        );

        UPDATE public.msip_ubicacionpre SET
          nombre=dpa[1],
          nombre_sin_pais=dpa[2],
          latitud=NEW.latitud,
          longitud=NEW.longitud,
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
            AND departamento_id=mi_departamento_id
            AND municipio_id=NEW.municipio_id
            AND centropoblado_id=NEW.id
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL;

        -- Actualizamos lo que está dentro del centropoblado en cascada (esperamos
        -- llamada al trigger de nomenclatura para arreglar nombre_sin_pais por
        -- ejemplo)
        UPDATE public.msip_ubicacionpre SET
          nombre=REPLACE(nombre, OLD.nombre, NEW.nombre),
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
          AND departamento_id=mi_departamento_id
          AND municipio_id=NEW.municipio_id
          AND centropoblado_id=NEW.id
          AND NOT (vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL);

        RETURN NULL;
      END ;
    $$;


--
-- Name: msip_ubicacionpre_tras_actualizar_departamento(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_actualizar_departamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE 
        dpa TEXT[];
        nompais TEXT;
      BEGIN
        ASSERT(TG_OP = 'UPDATE');
        RAISE NOTICE 'Actualizando departamento';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
        RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
        RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        nompais := COALESCE((SELECT nombre FROM public.msip_pais WHERE id=new.pais_id LIMIT 1), '');
        dpa := public.msip_ubicacionpre_dpa_nomenclatura(
         nompais, NEW.nombre, '', '', ''
        );
        UPDATE public.msip_ubicacionpre SET
          nombre=dpa[1],
          nombre_sin_pais=dpa[2],
          latitud=NEW.latitud,
          longitud=NEW.longitud,
          updated_at=NOW()
        WHERE pais_id=OLD.pais_id
            AND departamento_id=OLD.id
            AND municipio_id IS NULL
            AND centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL;

        -- Actualizamos lo que está dentro del departamento en cascada (esperamos 
        -- llamada al trigger de nomenclatura para arreglar nombre_sin_pais por 
        -- ejemplo)
        UPDATE public.msip_ubicacionpre SET
          nombre=REPLACE(nombre, OLD.nombre, NEW.nombre),
          updated_at=NOW()
        WHERE pais_id=OLD.pais_id 
          AND departamento_id=OLD.id 
          AND NOT (municipio_id IS NULL
            AND centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL);

        RETURN NULL;
      END ;
    $$;


--
-- Name: msip_ubicacionpre_tras_actualizar_municipio(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_actualizar_municipio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
      BEGIN
        ASSERT(TG_OP = 'UPDATE');
        RAISE NOTICE 'Actualizando municipio';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
        RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
        RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        mi_pais_id := (SELECT pais_id FROM public.msip_departamento
          WHERE id=new.departamento_id LIMIT 1);
        nompais := (SELECT nombre FROM public.msip_pais 
          WHERE id=mi_pais_id LIMIT 1);
        nomdepartamento := (SELECT nombre FROM public.msip_departamento
          WHERE id=new.departamento_id LIMIT 1);
        dpa := public.msip_ubicacionpre_dpa_nomenclatura(
          nompais, nomdepartamento, NEW.nombre, '', ''
        );

        UPDATE public.msip_ubicacionpre SET
          nombre=dpa[1],
          nombre_sin_pais=dpa[2],
          latitud=NEW.latitud,
          longitud=NEW.longitud,
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
            AND departamento_id=OLD.departamento_id
            AND municipio_id=OLD.id
            AND centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL;

        -- Actualizamos lo que está dentro del departamento en cascada (esperamos
        -- llamada al trigger de nomenclatura para arreglar nombre_sin_pais por
        -- ejemplo)
        UPDATE public.msip_ubicacionpre SET
          nombre=REPLACE(nombre, OLD.nombre, NEW.nombre),
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
          AND departamento_id=OLD.departamento_id
          AND municipio_id=OLD.id
          AND NOT (centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL);

        RETURN NULL;
      END ;
    $$;


--
-- Name: msip_ubicacionpre_tras_actualizar_pais(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_actualizar_pais() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE 
        dpa TEXT[];
      BEGIN
        ASSERT(TG_OP = 'UPDATE');
        RAISE NOTICE 'Actualizando pais';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
        RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
        RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        -- Actualizamos pais
        dpa := public.msip_ubicacionpre_dpa_nomenclatura(
          NEW.nombre, '', '', '', ''
        );
        UPDATE public.msip_ubicacionpre SET
          nombre=dpa[1],
          latitud=NEW.latitud,
          longitud=NEW.longitud,
          updated_at=NOW()
        WHERE pais_id=OLD.id
            AND departamento_id IS NULL 
            AND municipio_id IS NULL
            AND centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL;
        
        -- Actualizamos lo que está dentro del país en cascada (esperamos 
        -- llamada al trigger de nomenclatura para arreglar nombre_sin_pais por 
        -- ejemplo)
        UPDATE public.msip_ubicacionpre SET
          nombre=REPLACE(nombre, OLD.nombre, NEW.nombre),
          updated_at=NOW()
        WHERE pais_id=OLD.id
            AND NOT (departamento_id IS NULL 
            AND municipio_id IS NULL
            AND centropoblado_id IS NULL
            AND vereda_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL);

        RETURN NULL;
      END ;
    $$;


--
-- Name: msip_ubicacionpre_tras_actualizar_vereda(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_actualizar_vereda() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        mi_departamento_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
        nommunicipio TEXT;
      BEGIN
        ASSERT(TG_OP = 'UPDATE');
        RAISE NOTICE 'Actualizando vereda';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
        RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
        RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        mi_departamento_id := (SELECT departamento_id 
          FROM public.msip_municipio
          WHERE id=NEW.municipio_id LIMIT 1);
        mi_pais_id := (SELECT pais_id FROM public.msip_departamento
          WHERE id=mi_departamento_id LIMIT 1);
        nompais := (SELECT nombre FROM public.msip_pais 
          WHERE id=mi_pais_id LIMIT 1);
        nomdepartamento := (SELECT nombre FROM public.msip_departamento
          WHERE id=mi_departamento_id LIMIT 1);
        nommunicipio := (SELECT nombre FROM public.msip_municipio
          WHERE id=NEW.municipio_id LIMIT 1);

        dpa := public.msip_ubicacionpre_dpa_nomenclatura(
          nompais, nomdepartamento, nommunicipio, '', NEW.nombre
        );

        UPDATE public.msip_ubicacionpre SET
          nombre=dpa[1],
          nombre_sin_pais=dpa[2],
          latitud=NEW.latitud,
          longitud=NEW.longitud,
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
            AND departamento_id=mi_departamento_id
            AND municipio_id=NEW.municipio_id
            AND vereda_id=NEW.id
            AND centropoblado_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL;

        -- Actualizamos lo que está dentro de la vereda en cascada (esperamos
        -- llamada al trigger de nomenclatura para arreglar nombre_sin_pais por
        -- ejemplo)
        UPDATE public.msip_ubicacionpre SET
          nombre=REPLACE(nombre, OLD.nombre, NEW.nombre),
          updated_at=NOW()
        WHERE pais_id=mi_pais_id
          AND departamento_id=mi_departamento_id
          AND municipio_id=NEW.municipio_id
          AND vereda_id=NEW.id
          AND NOT (centropoblado_id IS NULL
            AND lugar IS NULL
            AND sitio IS NULL);

        RETURN NULL;
      END ;
    $$;


--
-- Name: msip_ubicacionpre_tras_crear_centropoblado(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_crear_centropoblado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        mi_departamento_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
        nommunicipio TEXT;
      BEGIN
        ASSERT(TG_OP = 'INSERT');
        -- Los comunes se insertan manualmente con ids. diseñadas
        IF NEW.id > 1000000 THEN
          RAISE NOTICE 'Insertando centro poblado propio';
          RAISE NOTICE 'TG_OP = %', TG_OP;
          RAISE NOTICE 'NEW.id = %', NEW.id;
          RAISE NOTICE 'NEW.municipio_id = %', NEW.municipio_id;
          RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
          RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
          RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
          RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

          mi_departamento_id := (SELECT departamento_id 
            FROM public.msip_municipio
            WHERE id=NEW.municipio_id LIMIT 1);
          mi_pais_id := (SELECT pais_id FROM public.msip_departamento
            WHERE id=mi_departamento_id LIMIT 1);
          nompais := (SELECT nombre FROM public.msip_pais 
            WHERE id=mi_pais_id LIMIT 1);
          nomdepartamento := (SELECT nombre FROM public.msip_departamento
            WHERE id=mi_departamento_id LIMIT 1);
          nommunicipio := (SELECT nombre FROM public.msip_municipio
            WHERE id=NEW.municipio_id LIMIT 1);
          dpa := public.msip_ubicacionpre_dpa_nomenclatura(
            nompais, nomdepartamento, nommunicipio, NEW.nombre, ''
          );
          INSERT INTO public.msip_ubicacionpre (nombre, pais_id,
            departamento_id, municipio_id, centropoblado_id, vereda_id,
            lugar, sitio, tsitio_id, latitud, longitud,
            nombre_sin_pais, observaciones,
            fechacreacion, fechadeshabilitacion, created_at, updated_at)
          VALUES (dpa[1], mi_pais_id, 
            mi_departamento_id, NEW.municipio_id, NEW.id, NULL,
            NULL, NULL, NULL, NEW.latitud, NEW.longitud,
            dpa[2], NULL,
            NEW.fechacreacion, NULL, NOW(), NOW());
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_tras_crear_departamento(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_crear_departamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        nompais TEXT;
      BEGIN
        ASSERT(TG_OP = 'INSERT');
        -- Los comunes se insertan manualmente con ids. diseñadas
        IF NEW.id > 10000 THEN
          RAISE NOTICE 'Insertando departamento propio';
          RAISE NOTICE 'TG_OP = %', TG_OP;
          RAISE NOTICE 'NEW.id = %', NEW.id;
          RAISE NOTICE 'NEW.pais_id = %', NEW.pais_id;
          RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
          RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
          RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
          RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

          nompais := COALESCE((SELECT nombre FROM public.msip_pais WHERE id=new.pais_id LIMIT 1), '');
          dpa := public.msip_ubicacionpre_dpa_nomenclatura(
           nompais, NEW.nombre, '', '', ''
          );
          INSERT INTO public.msip_ubicacionpre (nombre, pais_id,
            departamento_id, municipio_id, centropoblado_id, vereda_id,
            lugar, sitio, tsitio_id, latitud, longitud,
            nombre_sin_pais, observaciones,
            fechacreacion, fechadeshabilitacion, created_at, updated_at)
          VALUES (dpa[1], NEW.pais_id, NEW.id,
            NULL, NULL, NULL,
            NULL, NULL, NULL, NEW.latitud, NEW.longitud,
            dpa[2], NULL,
            NEW.fechacreacion, NULL, NOW(), NOW());
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_tras_crear_municipio(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_crear_municipio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
      BEGIN
        ASSERT(TG_OP = 'INSERT');
        -- Los comunes se insertan manualmente con ids. diseñadas
        IF NEW.id > 100000 THEN
          RAISE NOTICE 'Insertando departamento propio';
          RAISE NOTICE 'TG_OP = %', TG_OP;
          RAISE NOTICE 'NEW.id = %', NEW.id;
          RAISE NOTICE 'NEW.departamento_id = %', NEW.departamento_id;
          RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
          RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
          RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
          RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

          mi_pais_id := (SELECT pais_id FROM public.msip_departamento
            WHERE id=new.departamento_id LIMIT 1);
          nompais := (SELECT nombre FROM public.msip_pais 
            WHERE id=mi_pais_id LIMIT 1);
          nomdepartamento := (SELECT nombre FROM public.msip_departamento
            WHERE id=new.departamento_id LIMIT 1);
          dpa := public.msip_ubicacionpre_dpa_nomenclatura(
            nompais, nomdepartamento, NEW.nombre, '', ''
          );
          INSERT INTO public.msip_ubicacionpre (nombre, pais_id,
            departamento_id, municipio_id, centropoblado_id, vereda_id,
            lugar, sitio, tsitio_id, latitud, longitud,
            nombre_sin_pais, observaciones,
            fechacreacion, fechadeshabilitacion, created_at, updated_at)
          VALUES (dpa[1], mi_pais_id, 
            NEW.departamento_id, NEW.id, NULL, NULL,
            NULL, NULL, NULL, NEW.latitud, NEW.longitud,
            dpa[2], NULL,
            NEW.fechacreacion, NULL, NOW(), NOW());
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_tras_crear_pais(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_crear_pais() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
      BEGIN
        ASSERT(TG_OP = 'INSERT');
        -- Los comunes se insertan manualmente con ids. diseñadas
        IF NEW.id > 1000 THEN
          RAISE NOTICE 'Insertando pais propio';
          RAISE NOTICE 'TG_OP = %', TG_OP;
          RAISE NOTICE 'NEW.id = %', NEW.id;
          RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
          RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
          RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
          RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

          dpa := public.msip_ubicacionpre_dpa_nomenclatura(
           NEW.nombre, '', '', '', ''
          );
          INSERT INTO public.msip_ubicacionpre (nombre, pais_id,
            departamento_id, municipio_id, centropoblado_id, vereda_id,
            lugar, sitio, tsitio_id, latitud, longitud,
            nombre_sin_pais, observaciones,
            fechacreacion, fechadeshabilitacion, created_at, updated_at)
          VALUES (dpa[1], NEW.id,
            NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NEW.latitud, NEW.longitud,
            NULL, NULL,
            NEW.fechacreacion, NULL, NOW(), NOW());
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_ubicacionpre_tras_crear_vereda(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_tras_crear_vereda() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        dpa TEXT[];
        mi_pais_id INTEGER;
        mi_departamento_id INTEGER;
        nompais TEXT;
        nomdepartamento TEXT;
        nommunicipio TEXT;
      BEGIN
        ASSERT(TG_OP = 'INSERT');
        -- Los comunes se insertan manualmente con ids. diseñadas
        IF NEW.id > 1000000 THEN
          RAISE NOTICE 'Insertando centro poblado propio';
          RAISE NOTICE 'TG_OP = %', TG_OP;
          RAISE NOTICE 'NEW.id = %', NEW.id;
          RAISE NOTICE 'NEW.municipio_id = %', NEW.municipio_id;
          RAISE NOTICE 'NEW.nombre = %', NEW.nombre;
          RAISE NOTICE 'NEW.latitud = %', NEW.latitud;
          RAISE NOTICE 'NEW.longitud = %', NEW.longitud;
          RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

          mi_departamento_id := (SELECT departamento_id 
            FROM public.msip_municipio
            WHERE id=NEW.municipio_id LIMIT 1);
          RAISE NOTICE 'mi_departamento_id = %', mi_departamento_id;
          mi_pais_id := (SELECT pais_id FROM public.msip_departamento
            WHERE id=mi_departamento_id LIMIT 1);
          RAISE NOTICE 'mi_pais_id = %', mi_pais_id;
          nompais := (SELECT nombre FROM public.msip_pais 
            WHERE id=mi_pais_id LIMIT 1);
          RAISE NOTICE 'nompais = %', nompais;
          nomdepartamento := (SELECT nombre FROM public.msip_departamento
            WHERE id=mi_departamento_id LIMIT 1);
          RAISE NOTICE 'nomdepartamento = %', nomdepartamento;
          nommunicipio := (SELECT nombre FROM public.msip_municipio
            WHERE id=NEW.municipio_id LIMIT 1);
          RAISE NOTICE 'nommunicipio = %', nommunicipio;
          dpa := public.msip_ubicacionpre_dpa_nomenclatura(
            nompais, nomdepartamento, nommunicipio, NEW.nombre, ''
          );
          RAISE NOTICE 'dpa[0] = %', dpa[0];
          RAISE NOTICE 'dpa[1] = %', dpa[1];
          INSERT INTO public.msip_ubicacionpre (nombre, pais_id,
            departamento_id, municipio_id, centropoblado_id, vereda_id,
            lugar, sitio, tsitio_id, latitud, longitud,
            nombre_sin_pais, observaciones,
            fechacreacion, fechadeshabilitacion, created_at, updated_at)
          VALUES (dpa[1], mi_pais_id, 
            mi_departamento_id, NEW.municipio_id, NULL, NEW.id,
            NULL, NULL, NULL, NEW.latitud, NEW.longitud,
            dpa[2], NULL,
            NEW.fechacreacion, NULL, NOW(), NOW());
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
      	soundex text='';	
      	-- para determinar la primera letra
      	pri_letra text;
      	resto text;
      	sustituida text ='';
      	-- para quitar adyacentes
      	anterior text;
      	actual text;
      	corregido text;
      BEGIN
        --raise notice 'entrada=%', entrada;
        -- devolver null si recibi un string en blanco o con espacios en blanco
        IF length(trim(entrada))= 0 then
              RETURN NULL;
        END IF;


      	-- 1: LIMPIEZA:
      		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
      		-- 'holá coñó' => 'OLA CONO'
      		entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');

        IF array_upper(regexp_split_to_array(entrada, '[^a-zA-Z]'), 1) > 1 THEN
          RAISE NOTICE 'Esta función sólo maneja una palabra y no ''%''. Use más bien soundexespm', entrada;
      		RETURN NULL;
        END IF;

      	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
      	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
      	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
      	pri_letra =substr(entrada,1,1);
      	resto =substr(entrada,2);
      	CASE
      		when pri_letra IN ('V') then
      			sustituida='B';
      		when pri_letra IN ('Z','X') then
      			sustituida='S';
      		when pri_letra IN ('G') AND substr(entrada,2,1) IN ('E','I') then
      			sustituida='J';
      		when pri_letra IN('C') AND substr(entrada,2,1) NOT IN ('H','E','I') then
      			sustituida='K';
      		else
      			sustituida=pri_letra;

      	end case;
      	--corregir el parámetro con las consonantes sustituidas:
      	entrada=sustituida || resto;		
        --raise notice 'entrada tras cambios en primera letra %', entrada;

      	-- 3: corregir "letras compuestas" y volverlas una sola
      	entrada=REPLACE(entrada,'CH','V');
      	entrada=REPLACE(entrada,'QU','K');
      	entrada=REPLACE(entrada,'LL','J');
      	entrada=REPLACE(entrada,'CE','S');
      	entrada=REPLACE(entrada,'CI','S');
      	entrada=REPLACE(entrada,'YA','J');
      	entrada=REPLACE(entrada,'YE','J');
      	entrada=REPLACE(entrada,'YI','J');
      	entrada=REPLACE(entrada,'YO','J');
      	entrada=REPLACE(entrada,'YU','J');
      	entrada=REPLACE(entrada,'GE','J');
      	entrada=REPLACE(entrada,'GI','J');
      	entrada=REPLACE(entrada,'NY','N');
      	-- para debug:    --return entrada;
        --raise notice 'entrada tras cambiar letras compuestas %', entrada;

      	-- EMPIEZA EL CALCULO DEL SOUNDEX
      	-- 4: OBTENER PRIMERA letra
      	pri_letra=substr(entrada,1,1);

      	-- 5: retener el resto del string
      	resto=substr(entrada,2);

      	--6: en el resto del string, quitar vocales y vocales fonéticas
      	resto=translate(resto,'@AEIOUHWY','@');

      	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
      	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
      	-- así va quedando la cosa
      	soundex=pri_letra || resto;

      	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
      	anterior=substr(soundex,1,1);
      	corregido=anterior;

      	FOR i IN 2 .. length(soundex) LOOP
      		actual = substr(soundex, i, 1);
      		IF actual <> anterior THEN
      			corregido=corregido || actual;
      			anterior=actual;			
      		END IF;
      	END LOOP;
      	-- así va la cosa
      	soundex=corregido;

      	-- 9: siempre retornar un string de 4 posiciones
      	soundex=rpad(soundex,4,'0');
      	soundex=substr(soundex,1,4);		

      	-- YA ESTUVO
      	RETURN soundex;	
      END;	
      $$;


--
-- Name: soundexespm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexespm(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
        soundex text = '' ;
        partes text[];
        sep text = '';
        se text = '';
      BEGIN
        entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
        partes=regexp_split_to_array(entrada, '[^a-zA-Z]');

        --raise notice 'partes=%', partes;
        FOR i IN 1 .. array_upper(partes, 1) LOOP
          se = soundexesp(partes[i]);
          IF length(se) > 0 THEN
            soundex = soundex || sep || se;
            sep = ' ';
            --raise notice 'i=% . soundexesp=%', i, se;
          END IF;
        END LOOP;

      	RETURN soundex;	
      END;	
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mr519_gen_campo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_campo (
    id bigint NOT NULL,
    nombre character varying(512) NOT NULL,
    ayudauso character varying(1024),
    tipo integer DEFAULT 1 NOT NULL,
    obligatorio boolean,
    formulario_id integer NOT NULL,
    nombreinterno character varying(60),
    fila integer,
    columna integer,
    ancho integer,
    tablabasica character varying(32)
);


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_campo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_campo_id_seq OWNED BY public.mr519_gen_campo.id;


--
-- Name: mr519_gen_encuestapersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestapersona (
    id bigint NOT NULL,
    persona_id integer,
    fecha date,
    adurl character varying(32),
    respuestafor_id integer,
    planencuesta_id integer
);


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestapersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestapersona_id_seq OWNED BY public.mr519_gen_encuestapersona.id;


--
-- Name: mr519_gen_encuestausuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestausuario (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestausuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestausuario_id_seq OWNED BY public.mr519_gen_encuestausuario.id;


--
-- Name: mr519_gen_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_formulario (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    nombreinterno character varying(60)
);


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_formulario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_formulario_id_seq OWNED BY public.mr519_gen_formulario.id;


--
-- Name: mr519_gen_opcioncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_opcioncs (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    nombre character varying(1024) NOT NULL,
    valor character varying(60) NOT NULL
);


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_opcioncs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_opcioncs_id_seq OWNED BY public.mr519_gen_opcioncs.id;


--
-- Name: mr519_gen_planencuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_planencuesta (
    id bigint NOT NULL,
    fechaini date,
    fechafin date,
    formulario_id integer,
    plantillacorreoinv_id integer,
    adurl character varying(32),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_planencuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_planencuesta_id_seq OWNED BY public.mr519_gen_planencuesta.id;


--
-- Name: mr519_gen_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_respuestafor (
    id bigint NOT NULL,
    formulario_id integer,
    fechaini date NOT NULL,
    fechacambio date NOT NULL
);


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_respuestafor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_respuestafor_id_seq OWNED BY public.mr519_gen_respuestafor.id;


--
-- Name: mr519_gen_valorcampo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_valorcampo (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    valor character varying(5000),
    respuestafor_id integer NOT NULL,
    valorjson json
);


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_valorcampo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_valorcampo_id_seq OWNED BY public.mr519_gen_valorcampo.id;


--
-- Name: msip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_anexo (
    id integer DEFAULT nextval('public.msip_anexo_id_seq'::regclass) NOT NULL,
    descripcion character varying(1500) NOT NULL COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    adjunto_file_name character varying(255) NOT NULL,
    adjunto_content_type character varying(255) NOT NULL,
    adjunto_file_size integer NOT NULL,
    adjunto_updated_at timestamp without time zone
);


--
-- Name: msip_bitacora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_bitacora (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    ip character varying(100),
    usuario_id integer,
    url character varying(1023),
    params character varying(5000),
    modelo character varying(511),
    modelo_id integer,
    operacion character varying(63),
    detalle json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_bitacora_id_seq OWNED BY public.msip_bitacora.id;


--
-- Name: msip_centropoblado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_centropoblado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_centropoblado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_centropoblado (
    id integer DEFAULT nextval('public.msip_centropoblado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer NOT NULL,
    cplocal_cod integer,
    tcentropoblado_id character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT msip_centropoblado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_centropoblado_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_centropoblado_histvigencia (
    id bigint NOT NULL,
    centropoblado_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    cplocal_cod integer,
    tcentropoblado_id character varying,
    observaciones character varying(5000)
);


--
-- Name: msip_centropoblado_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_centropoblado_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_centropoblado_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_centropoblado_histvigencia_id_seq OWNED BY public.msip_centropoblado_histvigencia.id;


--
-- Name: msip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento (
    id integer DEFAULT nextval('public.msip_departamento_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer NOT NULL,
    deplocal_cod integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codiso character varying(6),
    catiso character varying(64),
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT departamento_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_departamento_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento_histvigencia (
    id bigint NOT NULL,
    departamento_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    deplocal_cod integer,
    codiso integer,
    catiso integer,
    codreg integer,
    observaciones character varying(5000)
);


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_departamento_histvigencia_id_seq OWNED BY public.msip_departamento_histvigencia.id;


--
-- Name: msip_estadosol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_estadosol (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_estadosol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_estadosol_id_seq OWNED BY public.msip_estadosol.id;


--
-- Name: msip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta (
    id integer DEFAULT nextval('public.msip_etiqueta_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etiqueta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_etiqueta_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta_municipio (
    etiqueta_id bigint NOT NULL,
    municipio_id bigint NOT NULL
);


--
-- Name: msip_etiqueta_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta_persona (
    id bigint NOT NULL,
    etiqueta_id integer NOT NULL,
    persona_id integer NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_etiqueta_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etiqueta_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etiqueta_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_etiqueta_persona_id_seq OWNED BY public.msip_etiqueta_persona.id;


--
-- Name: msip_etnia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etnia (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT etnia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_etnia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etnia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etnia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_etnia_id_seq OWNED BY public.msip_etnia.id;


--
-- Name: msip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_fuenteprensa (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: msip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_fuenteprensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_fuenteprensa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_fuenteprensa_id_seq OWNED BY public.msip_fuenteprensa.id;


--
-- Name: msip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_grupo_id_seq OWNED BY public.msip_grupo.id;


--
-- Name: msip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo_usuario (
    usuario_id integer NOT NULL,
    grupo_id integer NOT NULL
);


--
-- Name: msip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupoper (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    anotaciones character varying(1000)
);


--
-- Name: TABLE msip_grupoper; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.msip_grupoper IS 'Creado por sip en sipdes_des';


--
-- Name: msip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupoper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_grupoper_id_seq OWNED BY public.msip_grupoper.id;


--
-- Name: msip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio (
    id integer DEFAULT nextval('public.msip_municipio_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    departamento_id integer NOT NULL,
    munlocal_cod integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    tipomun character varying(32),
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT municipio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_mundep_sinorden; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.msip_mundep_sinorden AS
 SELECT ((msip_departamento.deplocal_cod * 1000) + msip_municipio.munlocal_cod) AS idlocal,
    (((msip_municipio.nombre)::text || ' / '::text) || (msip_departamento.nombre)::text) AS nombre
   FROM (public.msip_municipio
     JOIN public.msip_departamento ON ((msip_municipio.departamento_id = msip_departamento.id)))
  WHERE ((msip_departamento.pais_id = 170) AND (msip_municipio.fechadeshabilitacion IS NULL) AND (msip_departamento.fechadeshabilitacion IS NULL))
UNION
 SELECT msip_departamento.deplocal_cod AS idlocal,
    msip_departamento.nombre
   FROM public.msip_departamento
  WHERE ((msip_departamento.pais_id = 170) AND (msip_departamento.fechadeshabilitacion IS NULL));


--
-- Name: msip_mundep; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.msip_mundep AS
 SELECT idlocal,
    nombre,
    to_tsvector('spanish'::regconfig, public.unaccent(nombre)) AS mundep
   FROM public.msip_mundep_sinorden
  ORDER BY (nombre COLLATE public.es_co_utf_8)
  WITH NO DATA;


--
-- Name: msip_municipio_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio_histvigencia (
    id bigint NOT NULL,
    municipio_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    munlocal_cod integer,
    observaciones character varying(5000),
    codreg integer
);


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_municipio_histvigencia_id_seq OWNED BY public.msip_municipio_histvigencia.id;


--
-- Name: msip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_oficina_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_oficina (
    id integer DEFAULT nextval('public.msip_oficina_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT msip_oficina_fechadeshabilitacion_chequeo CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fechadeshabilitacion date,
    tipoorg_id integer DEFAULT 2 NOT NULL
);


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_id_seq OWNED BY public.msip_orgsocial.id;


--
-- Name: msip_orgsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    correo character varying(100),
    cargo character varying(254)
);


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_persona_id_seq OWNED BY public.msip_orgsocial_persona.id;


--
-- Name: msip_orgsocial_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_sectororgsocial (
    orgsocial_id integer,
    sectororgsocial_id integer
);


--
-- Name: msip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais (
    id integer DEFAULT nextval('public.msip_pais_id_seq'::regclass) NOT NULL,
    nombre character varying(200) COLLATE public.es_co_utf_8,
    nombreiso_espanol character varying(200),
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    nombreiso_ingles character varying(512),
    nombreiso_frances character varying(512),
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_pais_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais_histvigencia (
    id bigint NOT NULL,
    pais_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    codiso integer,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codcambio character varying(4)
);


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_pais_histvigencia_id_seq OWNED BY public.msip_pais_histvigencia.id;


--
-- Name: msip_perfilorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_perfilorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_perfilorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_perfilorgsocial_id_seq OWNED BY public.msip_perfilorgsocial.id;


--
-- Name: msip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona (
    id integer DEFAULT nextval('public.msip_persona_id_seq'::regclass) NOT NULL,
    nombres character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    apellidos character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character(1) NOT NULL,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer,
    nacionalde integer,
    tdocumento_id integer,
    etnia_id integer DEFAULT 1 NOT NULL,
    CONSTRAINT persona_check CHECK (((dianac IS NULL) OR (((dianac >= 1) AND (((mesnac = 1) OR (mesnac = 3) OR (mesnac = 5) OR (mesnac = 7) OR (mesnac = 8) OR (mesnac = 10) OR (mesnac = 12)) AND (dianac <= 31))) OR (((mesnac = 4) OR (mesnac = 6) OR (mesnac = 9) OR (mesnac = 11)) AND (dianac <= 30)) OR ((mesnac = 2) AND (dianac <= 29))))),
    CONSTRAINT persona_mesnac_check CHECK (((mesnac IS NULL) OR ((mesnac >= 1) AND (mesnac <= 12)))),
    CONSTRAINT persona_sexo_check CHECK (((sexo = 'S'::bpchar) OR (sexo = 'F'::bpchar) OR (sexo = 'M'::bpchar)))
);


--
-- Name: msip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_trelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona_trelacion (
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    trelacion_id character(2) DEFAULT 'SI'::bpchar NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.msip_persona_trelacion_id_seq'::regclass) NOT NULL
);


--
-- Name: msip_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_sectororgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_sectororgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_sectororgsocial_id_seq OWNED BY public.msip_sectororgsocial.id;


--
-- Name: msip_solicitud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    solicitud character varying(5000),
    estadosol_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_solicitud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_solicitud_id_seq OWNED BY public.msip_solicitud.id;


--
-- Name: msip_solicitud_usuarionotificar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud_usuarionotificar (
    usuarionotificar_id integer,
    solicitud_id integer
);


--
-- Name: msip_tcentropoblado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tcentropoblado (
    id character varying(10) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT msip_tcentropoblado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sigla character varying(500) NOT NULL,
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ayuda character varying(1000)
);


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tdocumento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tdocumento_id_seq OWNED BY public.msip_tdocumento.id;


--
-- Name: msip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tema (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    nav_ini character varying(8),
    nav_fin character varying(8),
    nav_fuente character varying(8),
    fondo_lista character varying(8),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    btn_primario_fondo_ini character varying(127),
    btn_primario_fondo_fin character varying(127),
    btn_primario_fuente character varying(127),
    btn_peligro_fondo_ini character varying(127),
    btn_peligro_fondo_fin character varying(127),
    btn_peligro_fuente character varying(127),
    btn_accion_fondo_ini character varying(127),
    btn_accion_fondo_fin character varying(127),
    btn_accion_fuente character varying(127),
    alerta_exito_fondo character varying(127),
    alerta_exito_fuente character varying(127),
    alerta_problema_fondo character varying(127),
    alerta_problema_fuente character varying(127),
    fondo character varying(127),
    color_fuente character varying(127),
    color_flota_subitem_fuente character varying,
    color_flota_subitem_fondo character varying
);


--
-- Name: msip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tema_id_seq OWNED BY public.msip_tema.id;


--
-- Name: msip_tipoorg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tipoorg (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tipoorg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tipoorg_id_seq OWNED BY public.msip_tipoorg.id;


--
-- Name: msip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trelacion (
    id character(2) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT trelacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_trivalente_id_seq OWNED BY public.msip_trivalente.id;


--
-- Name: msip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tsitio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tsitio (
    id integer DEFAULT nextval('public.msip_tsitio_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tsitio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacion (
    id integer DEFAULT nextval('public.msip_ubicacion_id_seq'::regclass) NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    centropoblado_id integer,
    municipio_id integer,
    departamento_id integer,
    tsitio_id integer DEFAULT 1 NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer
);


--
-- Name: msip_ubicacionpre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacionpre (
    id bigint NOT NULL,
    nombre character varying(2000) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer NOT NULL,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    lugar character varying(500),
    sitio character varying(500),
    tsitio_id integer,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nombre_sin_pais character varying(500),
    vereda_id integer,
    observaciones character varying(5000),
    fechacreacion date DEFAULT now() NOT NULL,
    fechadeshabilitacion date
);


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacionpre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_ubicacionpre_id_seq OWNED BY public.msip_ubicacionpre.id;


--
-- Name: msip_vereda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_vereda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer,
    verlocal_cod integer,
    observaciones character varying(5000),
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_vereda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_vereda_id_seq OWNED BY public.msip_vereda.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    nusuario character varying(15) NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    id integer DEFAULT nextval('public.usuario_id_seq'::regclass) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    failed_attempts integer,
    unlock_token character varying(64),
    locked_at timestamp without time zone,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    tema_id integer,
    CONSTRAINT usuario_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT usuario_rol_check CHECK ((rol >= 1))
);


--
-- Name: mr519_gen_campo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_campo_id_seq'::regclass);


--
-- Name: mr519_gen_encuestapersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestapersona_id_seq'::regclass);


--
-- Name: mr519_gen_encuestausuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestausuario_id_seq'::regclass);


--
-- Name: mr519_gen_formulario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_formulario_id_seq'::regclass);


--
-- Name: mr519_gen_opcioncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_opcioncs_id_seq'::regclass);


--
-- Name: mr519_gen_planencuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_planencuesta_id_seq'::regclass);


--
-- Name: mr519_gen_respuestafor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_respuestafor_id_seq'::regclass);


--
-- Name: mr519_gen_valorcampo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_valorcampo_id_seq'::regclass);


--
-- Name: msip_bitacora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora ALTER COLUMN id SET DEFAULT nextval('public.msip_bitacora_id_seq'::regclass);


--
-- Name: msip_centropoblado_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_centropoblado_histvigencia_id_seq'::regclass);


--
-- Name: msip_departamento_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_departamento_histvigencia_id_seq'::regclass);


--
-- Name: msip_estadosol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol ALTER COLUMN id SET DEFAULT nextval('public.msip_estadosol_id_seq'::regclass);


--
-- Name: msip_etiqueta_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_etiqueta_persona_id_seq'::regclass);


--
-- Name: msip_etnia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etnia ALTER COLUMN id SET DEFAULT nextval('public.msip_etnia_id_seq'::regclass);


--
-- Name: msip_fuenteprensa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa ALTER COLUMN id SET DEFAULT nextval('public.msip_fuenteprensa_id_seq'::regclass);


--
-- Name: msip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo ALTER COLUMN id SET DEFAULT nextval('public.msip_grupo_id_seq'::regclass);


--
-- Name: msip_grupoper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper ALTER COLUMN id SET DEFAULT nextval('public.msip_grupoper_id_seq'::regclass);


--
-- Name: msip_municipio_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_municipio_histvigencia_id_seq'::regclass);


--
-- Name: msip_orgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_id_seq'::regclass);


--
-- Name: msip_orgsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_persona_id_seq'::regclass);


--
-- Name: msip_pais_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_pais_histvigencia_id_seq'::regclass);


--
-- Name: msip_perfilorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_perfilorgsocial_id_seq'::regclass);


--
-- Name: msip_sectororgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_sectororgsocial_id_seq'::regclass);


--
-- Name: msip_solicitud id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud ALTER COLUMN id SET DEFAULT nextval('public.msip_solicitud_id_seq'::regclass);


--
-- Name: msip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.msip_tdocumento_id_seq'::regclass);


--
-- Name: msip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema ALTER COLUMN id SET DEFAULT nextval('public.msip_tema_id_seq'::regclass);


--
-- Name: msip_tipoorg id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg ALTER COLUMN id SET DEFAULT nextval('public.msip_tipoorg_id_seq'::regclass);


--
-- Name: msip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.msip_trivalente_id_seq'::regclass);


--
-- Name: msip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.msip_ubicacionpre_id_seq'::regclass);


--
-- Name: msip_vereda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda ALTER COLUMN id SET DEFAULT nextval('public.msip_vereda_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: mr519_gen_campo mr519_gen_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT mr519_gen_campo_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestapersona mr519_gen_encuestapersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT mr519_gen_encuestapersona_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestausuario mr519_gen_encuestausuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT mr519_gen_encuestausuario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_formulario mr519_gen_formulario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario
    ADD CONSTRAINT mr519_gen_formulario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_opcioncs mr519_gen_opcioncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT mr519_gen_opcioncs_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_planencuesta mr519_gen_planencuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta
    ADD CONSTRAINT mr519_gen_planencuesta_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_respuestafor mr519_gen_respuestafor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT mr519_gen_respuestafor_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_valorcampo mr519_gen_valorcampo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT mr519_gen_valorcampo_pkey PRIMARY KEY (id);


--
-- Name: msip_anexo msip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo
    ADD CONSTRAINT msip_anexo_pkey PRIMARY KEY (id);


--
-- Name: msip_bitacora msip_bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT msip_bitacora_pkey PRIMARY KEY (id);


--
-- Name: msip_centropoblado_histvigencia msip_centropoblado_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado_histvigencia
    ADD CONSTRAINT msip_centropoblado_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_centropoblado msip_centropoblado_id_municipio_id_cplocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_municipio_id_cplocal_key UNIQUE (municipio_id, cplocal_cod);


--
-- Name: msip_centropoblado msip_centropoblado_municipio_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_municipio_id_id_unico UNIQUE (municipio_id, id);


--
-- Name: msip_centropoblado msip_centropoblado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento_histvigencia msip_departamento_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia
    ADD CONSTRAINT msip_departamento_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento msip_departamento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_id_key UNIQUE (id);


--
-- Name: msip_departamento msip_departamento_id_pais_id_deplocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_id_pais_id_deplocal_unico UNIQUE (pais_id, deplocal_cod);


--
-- Name: msip_departamento msip_departamento_pais_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_pais_id_id_unico UNIQUE (pais_id, id);


--
-- Name: msip_departamento msip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_pkey PRIMARY KEY (id);


--
-- Name: msip_estadosol msip_estadosol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol
    ADD CONSTRAINT msip_estadosol_pkey PRIMARY KEY (id);


--
-- Name: msip_etiqueta_persona msip_etiqueta_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT msip_etiqueta_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_etiqueta msip_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta
    ADD CONSTRAINT msip_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: msip_etnia msip_etnia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etnia
    ADD CONSTRAINT msip_etnia_pkey PRIMARY KEY (id);


--
-- Name: msip_fuenteprensa msip_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa
    ADD CONSTRAINT msip_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: msip_grupo msip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo
    ADD CONSTRAINT msip_grupo_pkey PRIMARY KEY (id);


--
-- Name: msip_grupoper msip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper
    ADD CONSTRAINT msip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio msip_municipio_departamento_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_departamento_id_id_unico UNIQUE (departamento_id, id);


--
-- Name: msip_municipio_histvigencia msip_municipio_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia
    ADD CONSTRAINT msip_municipio_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio msip_municipio_id_departamento_id_munlocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_id_munlocal_unico UNIQUE (departamento_id, munlocal_cod);


--
-- Name: msip_municipio msip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_pkey PRIMARY KEY (id);


--
-- Name: msip_oficina msip_oficina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT msip_oficina_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial_persona msip_orgsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT msip_orgsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial msip_orgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT msip_orgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_codiso_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_codiso_unico UNIQUE (codiso);


--
-- Name: msip_pais_histvigencia msip_pais_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia
    ADD CONSTRAINT msip_pais_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_pkey PRIMARY KEY (id);


--
-- Name: msip_perfilorgsocial msip_perfilorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial
    ADD CONSTRAINT msip_perfilorgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_persona msip_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_id_key UNIQUE (id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_persona1_persona2_id_trelacion_key UNIQUE (persona1, persona2, trelacion_id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_persona1_persona2_id_trelacion_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_persona1_persona2_id_trelacion_key1 UNIQUE (persona1, persona2, trelacion_id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: msip_sectororgsocial msip_sectororgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial
    ADD CONSTRAINT msip_sectororgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_solicitud msip_solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT msip_solicitud_pkey PRIMARY KEY (id);


--
-- Name: msip_tcentropoblado msip_tcentropoblado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tcentropoblado
    ADD CONSTRAINT msip_tcentropoblado_pkey PRIMARY KEY (id);


--
-- Name: msip_tdocumento msip_tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento
    ADD CONSTRAINT msip_tdocumento_pkey PRIMARY KEY (id);


--
-- Name: msip_tema msip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema
    ADD CONSTRAINT msip_tema_pkey PRIMARY KEY (id);


--
-- Name: msip_tipoorg msip_tipoorg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg
    ADD CONSTRAINT msip_tipoorg_pkey PRIMARY KEY (id);


--
-- Name: msip_trelacion msip_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trelacion
    ADD CONSTRAINT msip_trelacion_pkey PRIMARY KEY (id);


--
-- Name: msip_trivalente msip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente
    ADD CONSTRAINT msip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: msip_tsitio msip_tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tsitio
    ADD CONSTRAINT msip_tsitio_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacion msip_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacionpre msip_ubicacionpre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT msip_ubicacionpre_pkey PRIMARY KEY (id);


--
-- Name: msip_vereda msip_vereda_municipio_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda
    ADD CONSTRAINT msip_vereda_municipio_id_id_unico UNIQUE (municipio_id, id);


--
-- Name: msip_vereda msip_vereda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda
    ADD CONSTRAINT msip_vereda_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: index_mr519_gen_encuestapersona_on_adurl; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mr519_gen_encuestapersona_on_adurl ON public.mr519_gen_encuestapersona USING btree (adurl);


--
-- Name: index_msip_orgsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_grupoper_id ON public.msip_orgsocial USING btree (grupoper_id);


--
-- Name: index_msip_orgsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_pais_id ON public.msip_orgsocial USING btree (pais_id);


--
-- Name: index_msip_persona_on_etnia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_persona_on_etnia_id ON public.msip_persona USING btree (etnia_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_solicitud_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_solicitud_id ON public.msip_solicitud_usuarionotificar USING btree (solicitud_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_usuarionotificar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_usuarionotificar_id ON public.msip_solicitud_usuarionotificar USING btree (usuarionotificar_id);


--
-- Name: index_msip_ubicacion_on_centropoblado_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_centropoblado_id ON public.msip_ubicacion USING btree (centropoblado_id);


--
-- Name: index_msip_ubicacion_on_departamento_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_departamento_id ON public.msip_ubicacion USING btree (departamento_id);


--
-- Name: index_msip_ubicacion_on_municipio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_municipio_id ON public.msip_ubicacion USING btree (municipio_id);


--
-- Name: index_msip_ubicacion_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_pais_id ON public.msip_ubicacion USING btree (pais_id);


--
-- Name: index_msip_ubicacionpre_on_vereda_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacionpre_on_vereda_id ON public.msip_ubicacionpre USING btree (vereda_id);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: msip_busca_mundep; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_busca_mundep ON public.msip_mundep USING gin (mundep);


--
-- Name: msip_nombre_ubicacionpre_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_nombre_ubicacionpre_b ON public.msip_ubicacionpre USING gin (to_tsvector('spanish'::regconfig, public.f_unaccent((nombre)::text)));


--
-- Name: msip_persona_anionac_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_anionac_ind ON public.msip_persona USING btree (anionac);


--
-- Name: msip_persona_sexo_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_sexo_ind ON public.msip_persona USING btree (sexo);


--
-- Name: msip_ubicacionpre_centropoblado_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_centropoblado_id_idx ON public.msip_ubicacionpre USING btree (centropoblado_id);


--
-- Name: msip_ubicacionpre_departamento_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_departamento_id_idx ON public.msip_ubicacionpre USING btree (departamento_id);


--
-- Name: msip_ubicacionpre_departamento_id_municipio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_departamento_id_municipio_id_idx ON public.msip_ubicacionpre USING btree (departamento_id, municipio_id);


--
-- Name: msip_ubicacionpre_municipio_id_centropoblado_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_centropoblado_id_idx ON public.msip_ubicacionpre USING btree (municipio_id, centropoblado_id);


--
-- Name: msip_ubicacionpre_municipio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_idx ON public.msip_ubicacionpre USING btree (municipio_id);


--
-- Name: msip_ubicacionpre_municipio_id_vereda_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_vereda_id_idx ON public.msip_ubicacionpre USING btree (municipio_id, vereda_id);


--
-- Name: msip_ubicacionpre_pais_id_departamento_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_departamento_id_idx ON public.msip_ubicacionpre USING btree (pais_id, departamento_id);


--
-- Name: msip_ubicacionpre_pais_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_idx ON public.msip_ubicacionpre USING btree (pais_id);


--
-- Name: msip_ubicacionpre_tsitio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_tsitio_id_idx ON public.msip_ubicacionpre USING btree (vereda_id);


--
-- Name: msip_ubicacionpre_vereda_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_vereda_id_idx ON public.msip_ubicacionpre USING btree (vereda_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: msip_centropoblado msip_antes_de_eliminar_centropoblado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_antes_de_eliminar_centropoblado BEFORE DELETE ON public.msip_centropoblado FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_centropoblado();


--
-- Name: msip_departamento msip_antes_de_eliminar_departamento; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_antes_de_eliminar_departamento BEFORE DELETE ON public.msip_departamento FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_departamento();


--
-- Name: msip_municipio msip_antes_de_eliminar_municipio; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_antes_de_eliminar_municipio BEFORE DELETE ON public.msip_municipio FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_municipio();


--
-- Name: msip_pais msip_antes_de_eliminar_pais; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_antes_de_eliminar_pais BEFORE DELETE ON public.msip_pais FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_pais();


--
-- Name: msip_vereda msip_antes_de_eliminar_vereda; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_antes_de_eliminar_vereda BEFORE DELETE ON public.msip_vereda FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_antes_de_eliminar_vereda();


--
-- Name: msip_persona_trelacion msip_eliminar_familiar; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_eliminar_familiar AFTER DELETE ON public.msip_persona_trelacion FOR EACH ROW EXECUTE FUNCTION public.msip_eliminar_familiar_inverso();


--
-- Name: msip_persona_trelacion msip_insertar_familiar; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_insertar_familiar AFTER INSERT OR UPDATE ON public.msip_persona_trelacion FOR EACH ROW EXECUTE FUNCTION public.msip_agregar_o_remplazar_familiar_inverso();


--
-- Name: msip_centropoblado msip_tras_actualizar_centropoblado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_actualizar_centropoblado AFTER UPDATE OF nombre, latitud, longitud ON public.msip_centropoblado FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_actualizar_centropoblado();


--
-- Name: msip_departamento msip_tras_actualizar_departamento; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_actualizar_departamento AFTER UPDATE OF nombre, latitud, longitud ON public.msip_departamento FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_actualizar_departamento();


--
-- Name: msip_municipio msip_tras_actualizar_municipio; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_actualizar_municipio AFTER UPDATE OF nombre, latitud, longitud ON public.msip_municipio FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_actualizar_municipio();


--
-- Name: msip_pais msip_tras_actualizar_pais; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_actualizar_pais AFTER UPDATE OF nombre, latitud, longitud ON public.msip_pais FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_actualizar_pais();


--
-- Name: msip_vereda msip_tras_actualizar_vereda; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_actualizar_vereda AFTER UPDATE OF nombre, latitud, longitud ON public.msip_vereda FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_actualizar_vereda();


--
-- Name: msip_centropoblado msip_tras_crear_centropoblado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_crear_centropoblado AFTER INSERT ON public.msip_centropoblado FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_crear_centropoblado();


--
-- Name: msip_departamento msip_tras_crear_departamento; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_crear_departamento AFTER INSERT ON public.msip_departamento FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_crear_departamento();


--
-- Name: msip_municipio msip_tras_crear_municipio; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_crear_municipio AFTER INSERT ON public.msip_municipio FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_crear_municipio();


--
-- Name: msip_pais msip_tras_crear_pais; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_crear_pais AFTER INSERT ON public.msip_pais FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_crear_pais();


--
-- Name: msip_vereda msip_tras_crear_vereda; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_tras_crear_vereda AFTER INSERT ON public.msip_vereda FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_tras_crear_vereda();


--
-- Name: msip_ubicacionpre tras_crear_o_actualizar_ubicacionpre; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tras_crear_o_actualizar_ubicacionpre BEFORE INSERT OR UPDATE OF pais_id, departamento_id, municipio_id, centropoblado_id, vereda_id, lugar, sitio, nombre ON public.msip_ubicacionpre FOR EACH ROW EXECUTE FUNCTION public.msip_ubicacionpre_actualiza_nombre();


--
-- Name: msip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_etiqueta_persona fk_rails_05a9a878fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_05a9a878fd FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: msip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_etiqueta_municipio fk_rails_10d88626c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_10d88626c3 FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_13f8d66312; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_13f8d66312 FOREIGN KEY (planencuesta_id) REFERENCES public.mr519_gen_planencuesta(id);


--
-- Name: msip_etiqueta_persona fk_rails_1856abc5d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_1856abc5d3 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_1b24d10e82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_1b24d10e82 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_2cb09d778a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_2cb09d778a FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: msip_bitacora fk_rails_2db961766c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT fk_rails_2db961766c FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_ubicacionpre fk_rails_2e86701dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_2e86701dfb FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_ubicacionpre fk_rails_3b59c12090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_3b59c12090 FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: msip_orgsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_54b3e0ed5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_54b3e0ed5c FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: msip_ubicacionpre fk_rails_558c98f353; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_558c98f353 FOREIGN KEY (vereda_id) REFERENCES public.msip_vereda(id);


--
-- Name: msip_etiqueta_municipio fk_rails_5672729520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_5672729520 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_orgsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.msip_grupoper(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_6296c40917; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_6296c40917 FOREIGN KEY (solicitud_id) REFERENCES public.msip_solicitud(id);


--
-- Name: mr519_gen_opcioncs fk_rails_656b4a3ca7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT fk_rails_656b4a3ca7 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: msip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_orgsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: mr519_gen_respuestafor fk_rails_805efe6935; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT fk_rails_805efe6935 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: mr519_gen_valorcampo fk_rails_819cf17399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_819cf17399 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_83755e20b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_83755e20b9 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: mr519_gen_valorcampo fk_rails_8bb7650018; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_8bb7650018 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: msip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (grupo_id) REFERENCES public.msip_grupo(id);


--
-- Name: msip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectororgsocial_id) REFERENCES public.msip_sectororgsocial(id);


--
-- Name: mr519_gen_campo fk_rails_a186e1a8a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT fk_rails_a186e1a8a0 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: msip_solicitud fk_rails_a670d661ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_a670d661ef FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_etiqueta_persona fk_rails_beb3a49837; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_beb3a49837 FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: msip_ubicacionpre fk_rails_c08a606417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c08a606417 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_ubicacionpre fk_rails_c8024a90df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c8024a90df FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.msip_tema(id);


--
-- Name: msip_persona fk_rails_d5b92f1c45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT fk_rails_d5b92f1c45 FOREIGN KEY (etnia_id) REFERENCES public.msip_etnia(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_db0f7c1dd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_db0f7c1dd6 FOREIGN KEY (usuarionotificar_id) REFERENCES public.usuario(id);


--
-- Name: msip_ubicacionpre fk_rails_eba8cc9124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_eba8cc9124 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: msip_centropoblado fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_solicitud fk_rails_ffa31a0de6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_ffa31a0de6 FOREIGN KEY (estadosol_id) REFERENCES public.msip_estadosol(id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_departamento_municipio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_departamento_municipio FOREIGN KEY (departamento_id, municipio_id) REFERENCES public.msip_municipio(departamento_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_municipio_centropoblado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_municipio_centropoblado FOREIGN KEY (municipio_id, centropoblado_id) REFERENCES public.msip_centropoblado(municipio_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_municipio_vereda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_municipio_vereda FOREIGN KEY (municipio_id, vereda_id) REFERENCES public.msip_vereda(municipio_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_pais_departamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_pais_departamento FOREIGN KEY (pais_id, departamento_id) REFERENCES public.msip_departamento(pais_id, id);


--
-- Name: msip_centropoblado msip_centropoblado_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_centropoblado msip_centropoblado_id_tcentropoblado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_tcentropoblado_fkey FOREIGN KEY (tcentropoblado_id) REFERENCES public.msip_tcentropoblado(id);


--
-- Name: msip_municipio msip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_persona msip_persona_centropoblado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_centropoblado_id_fkey FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: msip_ubicacion msip_ubicacion_centropoblado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_centropoblado_id_fkey FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: msip_persona persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.msip_tdocumento(id);


--
-- Name: msip_persona_trelacion persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (trelacion_id) REFERENCES public.msip_trelacion(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.msip_persona(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.msip_persona(id);


--
-- Name: msip_ubicacion ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_ubicacion ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_ubicacion ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250128142614'),
('20250128092632'),
('20250126220001'),
('20250124170451'),
('20241113141404'),
('20240723152453'),
('20240723140427'),
('20240722133233'),
('20240719195316'),
('20240718234057'),
('20240718234030'),
('20240715230510'),
('20240424122935'),
('20240221002426'),
('20240220164637'),
('20240220111410'),
('20240219221519'),
('20240219220944'),
('20231208162022'),
('20231205205600'),
('20231205205549'),
('20231205202418'),
('20231125230000'),
('20231125152810'),
('20231125152802'),
('20231124200056'),
('20231121203443'),
('20231120094041'),
('20231007095930'),
('20230927001422'),
('20230723011110'),
('20230722180204'),
('20230712163859'),
('20230622205530'),
('20230616203948'),
('20230613111532'),
('20230504084246'),
('20230404025025'),
('20230301212546'),
('20230301145222'),
('20221212021533'),
('20221211141209'),
('20221211141208'),
('20221211141207'),
('20221210155527'),
('20221208173349'),
('20221201154025'),
('20221201143440'),
('20221118032223'),
('20221102145906'),
('20221102144613'),
('20221025025402'),
('20221024222000'),
('20221024221557'),
('20220822132754'),
('20220808141102'),
('20220805181901'),
('20220722192214'),
('20220722000850'),
('20220721200858'),
('20220721170452'),
('20220719111148'),
('20220714191555'),
('20220714191510'),
('20220714191505'),
('20220714191500'),
('20220713200444'),
('20220713200101'),
('20220613224844'),
('20220428145059'),
('20220422190546'),
('20220420154535'),
('20220420143020'),
('20220417221010'),
('20220417220914'),
('20220417203841'),
('20220413123127'),
('20220215095957'),
('20220214232150'),
('20220214121713'),
('20220213031520'),
('20211216125250'),
('20211117200456'),
('20211024105450'),
('20211010164634'),
('20210728214424'),
('20210616003251'),
('20210614120835'),
('20210414201956'),
('20210401210102'),
('20210401194637'),
('20201124145625'),
('20201124142002'),
('20201124050637'),
('20201124035715'),
('20201119125643'),
('20200921123831'),
('20200919003430'),
('20200916022934'),
('20200907174303'),
('20200907165157'),
('20200727021707'),
('20200723133542'),
('20200722210144'),
('20200319183515'),
('20200228235200'),
('20191219011910'),
('20191205204511'),
('20191205202150'),
('20191205200007'),
('20190926104116'),
('20190830172824'),
('20190818013251'),
('20190804223012'),
('20190726203302'),
('20190715182611'),
('20190715083916'),
('20190703044126'),
('20190625112649'),
('20190618135559'),
('20190612111043'),
('20190605143420'),
('20190426125052'),
('20190418123920'),
('20190418014012'),
('20190418011743'),
('20190406164301'),
('20190406141156'),
('20190401175521'),
('20190331111015'),
('20190326150948'),
('20190322102311'),
('20190208103518'),
('20190110191802'),
('20190109125417'),
('20181227210510'),
('20181227114431'),
('20181227100523'),
('20181227095037'),
('20181227094559'),
('20181227093834'),
('20181219085236'),
('20181218215222'),
('20181218165559'),
('20181218165548'),
('20181213103204'),
('20181012110629'),
('20181011104537'),
('20180921120954'),
('20180920031351'),
('20180917072914'),
('20180914153010'),
('20180912114413'),
('20180905031617'),
('20180905031342'),
('20180810221619'),
('20180724202353'),
('20180724135332'),
('20180720171842'),
('20180720140443'),
('20180717135811'),
('20180509111948'),
('20180427194732'),
('20180320230847'),
('20171019133203'),
('20170414035328'),
('20170413185012'),
('20170405104322'),
('20161108102349'),
('20161103083352'),
('20161103081041'),
('20161103080156'),
('20161027233011'),
('20161026110802'),
('20161010152631'),
('20161009111443'),
('20160519195544'),
('20151020203421'),
('20150809032138'),
('20150803082520'),
('20150724003736'),
('20150717101243'),
('20150710114451'),
('20150707164448'),
('20150528100944'),
('20150521181918'),
('20150510125926'),
('20150503120915'),
('20150416074423'),
('20150413160159'),
('20150413160158'),
('20150413160157'),
('20150413160156');

