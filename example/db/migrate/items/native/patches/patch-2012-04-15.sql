CREATE TYPE UserAttributesType AS (
    State VARCHAR,
    Roles VARCHAR[],
    Markers VARCHAR[]
);

CREATE TYPE IdentityAttributesType AS (
    IdentityUri VARCHAR,
    State VARCHAR,
    Roles VARCHAR[],
    Markers VARCHAR[]
);

CREATE OR REPLACE FUNCTION UserPropertiesGet_v3(
        ExcKey UserMarkers.ItemExcKey%TYPE,
        IdentityUris VARCHAR[]
) RETURNS SETOF IdentityAttributesType AS $$
BEGIN

        RETURN QUERY(
        SELECT IdentityURI, s.IdentityState, r.IdentityRoleArray, m.IdentityMarkerArray
        FROM unnest(IdentityUris) IdentityURI
        LEFT JOIN IdentityStates AS s ON IdentityURI = s.ItemIdentityURI AND s.ItemExcKey=ExcKey
        LEFT JOIN
            (SELECT ItemIdentityURI, array_agg(IdentityRole) IdentityRoleArray
            FROM IdentityRoles WHERE ItemExcKey=ExcKey AND ItemIdentityURI = ANY(IdentityUris) GROUP BY ItemIdentityURI) AS r
            ON IdentityURI = r.ItemIdentityURI
        LEFT JOIN
            (SELECT ItemIdentityURI, array_agg(IdentityMarker) IdentityMarkerArray
            FROM IdentityMarkers WHERE ItemExcKey=ExcKey AND ItemIdentityURI = ANY(IdentityUris) GROUP BY ItemIdentityURI) AS m
            ON IdentityURI = m.ItemIdentityURI
        );
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserPropertiesGet_v3(
        ExcKey UserMarkers.ItemExcKey%TYPE,
        IdentityUris VARCHAR[]
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserAccPropertiesUpdate(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    IsUpdateState BOOLEAN,
    NewState VARCHAR,
    IsUpdateRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdateMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) RETURNS INTEGER AS $$
BEGIN
    IF IsUpdateState THEN
        PERFORM UserStateSet(NewItemUserId, NewItemExcKey, NewIdentityUris, NewState);
    END IF;
    IF IsUpdateRoles THEN
        PERFORM UserRolesSet(NewItemUserId, NewItemExcKey, NewIdentityUris, NewRoles);
    END IF;
    IF IsUpdateMarkers THEN
        PERFORM UserMarkersSet(NewItemUserId, NewItemExcKey, NewIdentityUris, NewMarkers);
    END IF;
    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserAccPropertiesUpdate(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    IsUpdateState BOOLEAN,
    NewState VARCHAR,
    IsUpdateRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdateMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserAccPropertiesGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE
) RETURNS SETOF UserAttributesType AS $$
DECLARE
    attr UserAttributesType%ROWTYPE;
BEGIN
    SELECT a INTO attr.State FROM UserStateGet(NewItemUserId, NewItemExcKey) AS a;
    SELECT array_agg(b) INTO attr.Roles FROM UserRolesGet(NewItemUserId, NewItemExcKey) AS b;
    SELECT array_agg(c) INTO attr.Markers FROM UserMarkersGet(NewItemUserId, NewItemExcKey) AS c;
    RETURN NEXT attr;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserAccPropertiesGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserAccPropertiesGetUpdateGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    IsUpdateState BOOLEAN,
    NewState VARCHAR,
    IsUpdateRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdateMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) RETURNS SETOF UserAttributesType AS $$
DECLARE
    attr_old UserAttributesType%ROWTYPE;
    attr_new UserAttributesType%ROWTYPE;
BEGIN
    RETURN QUERY (SELECT * FROM UserAccPropertiesGet(NewItemUserId, NewItemExcKey));
    PERFORM UserAccPropertiesUpdate(NewItemUserId, NewItemExcKey, NewIdentityUris,
        IsUpdateState, NewState, IsUpdateRoles, NewRoles, IsUpdateMarkers, NewMarkers);
    RETURN QUERY (SELECT * FROM UserAccPropertiesGet(NewItemUserId, NewItemExcKey));
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserAccPropertiesGetUpdateGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    IsUpdateState BOOLEAN,
    NewState VARCHAR,
    IsUpdateRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdateMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) TO PUBLIC;
