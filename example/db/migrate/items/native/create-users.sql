-- Tables

CREATE TABLE UserMarkers (
    id SERIAL,
    ItemUserId VARCHAR NOT NULL,
    ItemExcKey VARCHAR NOT NULL,
    UserMarker VARCHAR NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (ItemUserId, ItemExcKey, UserMarker)
) WITHOUT OIDS;

CREATE TABLE UserStates (
    id SERIAL,
    ItemUserId VARCHAR NOT NULL,
    ItemExcKey VARCHAR NOT NULL,
    UserState VARCHAR NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (ItemUserId, ItemExcKey)
) WITHOUT OIDS;

CREATE TABLE UserRoles (
    id SERIAL,
    ItemUserId VARCHAR NOT NULL,
    ItemExcKey VARCHAR NOT NULL,
    UserRole VARCHAR NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (ItemUserId, ItemExcKey, UserRole)
) WITHOUT OIDS;

CREATE TABLE IdentityMarkers (
    ItemIdentityUri VARCHAR NOT NULL,
    UserMarkerId INTEGER,
    ItemExcKey VARCHAR NOT NULL,
    IdentityMarker VARCHAR NOT NULL,
    PRIMARY KEY (ItemIdentityUri, ItemExcKey, IdentityMarker),
    FOREIGN KEY (UserMarkerId) REFERENCES UserMarkers(id) ON DELETE CASCADE
) WITHOUT OIDS;

CREATE TABLE IdentityRoles (
    ItemIdentityUri VARCHAR NOT NULL,
    UserRoleId INTEGER,
    ItemExcKey VARCHAR NOT NULL,
    IdentityRole VARCHAR NOT NULL,
    PRIMARY KEY (ItemIdentityUri, ItemExcKey, IdentityRole),
    FOREIGN KEY (UserRoleId) REFERENCES UserRoles(id) ON DELETE CASCADE
) WITHOUT OIDS;

CREATE TABLE IdentityStates (
    ItemIdentityUri VARCHAR NOT NULL,
    UserStateId INTEGER,
    ItemExcKey VARCHAR NOT NULL,
    IdentityState VARCHAR NOT NULL,
    PRIMARY KEY (ItemIdentityUri, ItemExcKey),
    FOREIGN KEY (UserStateId) REFERENCES UserStates(id) ON DELETE CASCADE
) WITHOUT OIDS;


-- Procedures

CREATE OR REPLACE FUNCTION UserMarkersAdd(
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserMarkers VARCHAR[]
) RETURNS INTEGER AS $$
DECLARE
    user_marker_id UserMarkers.id%TYPE;
BEGIN
    FOR m IN 1 .. ARRAY_UPPER(NewUserMarkers, 1) LOOP
        SELECT id INTO user_marker_id FROM UserMarkers
            WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserMarker = NewUserMarkers[m];
        IF user_marker_id IS NULL THEN
            INSERT INTO UserMarkers (ItemUserId, ItemExcKey, UserMarker)
            VALUES (NewItemUserId, NewItemExcKey, NewUserMarkers[m])
            RETURNING id INTO user_marker_id;
        END IF;
        DELETE FROM IdentityMarkers WHERE UserMarkerId = user_marker_id;
        FOR i IN 1 .. ARRAY_UPPER(NewIdentityUris, 1) LOOP
            INSERT INTO IdentityMarkers (ItemIdentityUri, UserMarkerId, ItemExcKey, IdentityMarker)
                VALUES (NewIdentityUris[i], user_marker_id, NewItemExcKey, NewUserMarkers[m]);
        END LOOP;
    END LOOP;
    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserMarkersSet (
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserMarkers VARCHAR[]
) RETURNS INTEGER AS $$
BEGIN
    IF ARRAY_UPPER(NewIdentityUris, 1) IS NULL THEN
        RAISE EXCEPTION 'Identities list can not be empty';
    END IF;

    DELETE FROM UserMarkers WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
    IF
        NewUserMarkers IS NOT NULL
        AND ARRAY_UPPER(NewUserMarkers, 1) IS NOT NULL
    THEN
        PERFORM UserMarkersAdd(NewItemUserId, NewItemExcKey, NewIdentityUris, NewUserMarkers);
    END IF;
    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserRolesAdd (
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserRoles VARCHAR[]
) RETURNS INTEGER AS $$
DECLARE
    new_user_role UserRoles.UserRole%TYPE;
    user_role_id UserRoles.id%TYPE;
BEGIN
    FOR m IN 1 .. ARRAY_UPPER(NewUserRoles, 1) LOOP
        SELECT id INTO user_role_id FROM UserRoles
            WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserRole = NewUserRoles[m];
        IF user_role_id IS NULL THEN
            INSERT INTO UserRoles (ItemUserId, ItemExcKey, UserRole)
            VALUES (NewItemUserId, NewItemExcKey, NewUserRoles[m])
            RETURNING id INTO user_role_id;
        END IF;
        DELETE FROM IdentityRoles WHERE UserRoleId = user_role_id;
        FOR i IN 1 .. ARRAY_UPPER(NewIdentityUris, 1) LOOP
            INSERT INTO IdentityRoles (ItemIdentityUri, UserRoleId, ItemExcKey, IdentityRole)
                VALUES (NewIdentityUris[i], user_role_id, NewItemExcKey, NewUserRoles[m]);
        END LOOP;
    END LOOP;
    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserRolesSet(
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserRoles VARCHAR[]
) RETURNS INTEGER AS $$
BEGIN
    IF ARRAY_UPPER(NewIdentityUris, 1) IS NULL THEN
        RAISE EXCEPTION 'Identities list can not be empty';
    END IF;

    DELETE FROM UserRoles WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
    IF
        NewUserRoles IS NOT NULL
        AND ARRAY_UPPER(NewUserRoles, 1) IS NOT NULL
    THEN
        PERFORM UserRolesAdd(NewItemUserId, NewItemExcKey, NewIdentityUris, NewUserRoles);
    END IF;
    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserStateSet (
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserState UserStates.UserState%TYPE
) RETURNS INTEGER AS $$
DECLARE
    user_state_id UserStates.id%TYPE;
BEGIN
    IF ARRAY_UPPER(NewIdentityUris, 1) IS NULL THEN
        RAISE EXCEPTION 'Identities list can not be empty';
    END IF;

    DELETE FROM IdentityStates WHERE UserStateId IN
        (SELECT id FROM UserStates WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);

    IF
        NewUserState IS NULL
        OR NewUserState = 'Untouched'
    THEN
        DELETE FROM UserStates WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
    ELSE
        UPDATE UserStates SET UserState = NewUserState
            WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey
            RETURNING id INTO user_state_id;
        IF NOT found THEN
            INSERT INTO UserStates (ItemUserId, ItemExcKey, UserState)
                VALUES (NewItemUserId, NewItemExcKey, NewUserState)
                RETURNING id INTO user_state_id;
        END IF;
        FOR i IN 1 .. ARRAY_UPPER(NewIdentityUris, 1) LOOP
            INSERT INTO IdentityStates (ItemIdentityUri, UserStateId, ItemExcKey, IdentityState)
                VALUES (NewIdentityUris[i], user_state_id, NewItemExcKey, NewUserState);
        END LOOP;
    END IF;

    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserRenewAttributes(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[]
) RETURNS INTEGER AS $$
DECLARE
    state VARCHAR;
    markers VARCHAR[];
    roles VARCHAR[];
BEGIN
    -- Renewing state
    SELECT a INTO state FROM UserStateGet(NewItemUserId, NewItemExcKey) AS a;
    PERFORM UserStateSet(NewItemUserId, NewItemExcKey, NewIdentityUris, state);

    -- Renewing markers
    SELECT array_agg(a) INTO markers FROM UserMarkersGet(NewItemUserId, NewItemExcKey) AS a;
    PERFORM UserMarkersSet(NewItemUserId, NewItemExcKey, NewIdentityUris, markers);

    -- Renewing roles
    SELECT array_agg(a) INTO roles FROM UserRolesGet(NewItemUserId, NewItemExcKey) AS a;
    PERFORM UserRolesSet(NewItemUserId, NewItemExcKey, NewIdentityUris, roles);

    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserMarkersGet (
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE
) RETURNS TABLE(m VARCHAR) AS $$
BEGIN
    RETURN QUERY(
    SELECT UserMarker FROM UserMarkers
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserStateGet (
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE
) RETURNS VARCHAR AS $$
DECLARE
    state VARCHAR;
BEGIN
    SELECT UserState INTO state FROM UserStates
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
    RETURN state;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserRolesGet (
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE
) RETURNS TABLE(m VARCHAR) AS $$
BEGIN
    RETURN QUERY(
    SELECT UserRole FROM UserRoles
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION UserDeleteAttributes(
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
BEGIN
    DELETE FROM UserStates
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

    DELETE FROM UserMarkers
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

    DELETE FROM UserRoles
    WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

    RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;


-- Grants

GRANT SELECT ON TABLE UserMarkers TO PUBLIC;
GRANT SELECT ON TABLE UserStates TO PUBLIC;
GRANT SELECT ON TABLE UserRoles TO PUBLIC;
GRANT SELECT ON TABLE IdentityMarkers TO PUBLIC;
GRANT SELECT ON TABLE IdentityRoles TO PUBLIC;
GRANT SELECT ON TABLE IdentityStates TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserMarkersSet(
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserMarkers VARCHAR[]
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserRolesSet(
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserRoles VARCHAR[]
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserStateSet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    NewUserState UserStates.UserState%TYPE
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserRenewAttributes(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[]
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserMarkersGet(
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserRolesGet(
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserStateGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserDeleteAttributes(
    NewItemUserId UserMarkers.ItemUserId%TYPE,
    NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;

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
    IsUpdatedState BOOLEAN,
    NewState VARCHAR,
    IsUpdatedRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdatedMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) RETURNS INTEGER AS $$
BEGIN
    IF IsUpdatedState THEN
        PERFORM UserStateSet(NewItemUserId, NewItemExcKey, NewIdentityUris, NewState);
    END IF;
    IF IsUpdatedRoles THEN
        PERFORM UserRolesSet(NewItemUserId, NewItemExcKey, NewIdentityUris, NewRoles);
    END IF;
    IF IsUpdatedMarkers THEN
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
    IsUpdatedState BOOLEAN,
    NewState VARCHAR,
    IsUpdatedRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdatedMarkers BOOLEAN,
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
    IsUpdatedState BOOLEAN,
    NewState VARCHAR,
    IsUpdatedRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdatedMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) RETURNS SETOF UserAttributesType AS $$
DECLARE
    attr_old UserAttributesType%ROWTYPE;
    attr_new UserAttributesType%ROWTYPE;
BEGIN
    RETURN QUERY (SELECT * FROM UserAccPropertiesGet(NewItemUserId, NewItemExcKey));
    PERFORM UserAccPropertiesUpdate(NewItemUserId, NewItemExcKey, NewIdentityUris,
        IsUpdatedState, NewState, IsUpdatedRoles, NewRoles, IsUpdatedMarkers, NewMarkers);
    RETURN QUERY (SELECT * FROM UserAccPropertiesGet(NewItemUserId, NewItemExcKey));
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserAccPropertiesGetUpdateGet(
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE,
    NewIdentityUris VARCHAR[],
    IsUpdatedState BOOLEAN,
    NewState VARCHAR,
    IsUpdatedRoles BOOLEAN,
    NewRoles VARCHAR[],
    IsUpdatedMarkers BOOLEAN,
    NewMarkers VARCHAR[]
) TO PUBLIC;
