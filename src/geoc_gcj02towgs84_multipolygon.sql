CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN source_geom;
    END IF;
        FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
                single_polygon_trans := geoc_gcj02towgs84_polygon(single_polygon); 
                target_parts := array_append(target_parts,single_polygon_trans);
        END LOOP;
				
        SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
        raise NOTICE 'final_geom: %',final_geom;
        RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100