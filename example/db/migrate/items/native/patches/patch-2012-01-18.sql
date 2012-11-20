CREATE OR REPLACE FUNCTION UserPropertiesGet(
        ExcKey UserMarkers.ItemExcKey%TYPE,
        IdentityUris VARCHAR[]
) RETURNS TABLE(id VARCHAR, proptype VARCHAR, value VARCHAR) AS $$
DECLARE
        user_marker_id UserMarkers.id%TYPE;
BEGIN

        RETURN QUERY(
                (SELECT ItemIdentityURI, 'states'::varchar AS PropType, IdentityState FROM IdentityStates
                        WHERE ItemExcKey=ExcKey AND ItemIdentityURI = ANY(IdentityUris))
                UNION
                (SELECT ItemIdentityURI, 'roles'::varchar AS PropType, IdentityRole FROM IdentityRoles
                        WHERE ItemExcKey=ExcKey AND ItemIdentityURI = ANY(IdentityUris))
                UNION
                (SELECT ItemIdentityURI, 'markers'::varchar AS PropType, IdentityMarker FROM IdentityMarkers
                        WHERE ItemExcKey=ExcKey AND ItemIdentityURI = ANY(IdentityUris))
        );
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserPropertiesGet(
        ExcKey UserMarkers.ItemExcKey%TYPE,
        IdentityUris VARCHAR[]
) TO PUBLIC;

