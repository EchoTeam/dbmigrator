DROP TABLE IF EXISTS IdentityStates;
DROP TABLE IF EXISTS IdentityMarkers;
DROP TABLE IF EXISTS UserStates;
DROP TABLE IF EXISTS UserMarkers;

CREATE TABLE UserMarkers (
	id SERIAL,
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserMarker VARCHAR NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (ItemUserId, ItemExcKey, UserMarker)
) WITHOUT OIDS;
GRANT SELECT ON TABLE UserMarkers TO PUBLIC;

CREATE TABLE UserStates (
	id SERIAL,
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserState VARCHAR NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (ItemUserId, ItemExcKey, UserState)
) WITHOUT OIDS;
GRANT SELECT ON TABLE UserStates TO PUBLIC;

CREATE TABLE IdentityMarkers (
	ItemIdentityUri VARCHAR NOT NULL,
	UserMarkerId INTEGER,
	ItemExcKey VARCHAR NOT NULL,
	IdentityMarker VARCHAR NOT NULL,
	PRIMARY KEY (ItemIdentityUri, ItemExcKey, IdentityMarker),
	FOREIGN KEY (UserMarkerId) REFERENCES UserMarkers (id)
) WITHOUT OIDS;
GRANT SELECT ON TABLE IdentityMarkers TO PUBLIC;

CREATE TABLE IdentityStates (
	ItemIdentityUri VARCHAR NOT NULL,
	UserStateId INTEGER,
	ItemExcKey VARCHAR NOT NULL,
	IdentityState VARCHAR NOT NULL,
	PRIMARY KEY (ItemIdentityUri, ItemExcKey, IdentityState),
	FOREIGN KEY (UserStateId) REFERENCES UserStates (id)
) WITHOUT OIDS;
GRANT SELECT ON TABLE IdentityStates TO PUBLIC;

CREATE OR REPLACE FUNCTION DeleteIdentitiesStates (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
DECLARE
	state_id INTEGER;
BEGIN
	FOR state_id IN SELECT id FROM UserStates WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey LOOP
		DELETE FROM IdentityStates WHERE UserStateId=state_id;
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION DeleteIdentitiesStates(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION IdentityStateSet (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewIdentityUri IdentityStates.ItemIdentityUri%TYPE,
	NewIdentityState IdentityStates.IdentityState%TYPE
) RETURNS INTEGER AS $$
DECLARE
	state_id INTEGER;
BEGIN
	FOR state_id IN SELECT id FROM UserStates WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey LOOP
		INSERT INTO IdentityStates (ItemIdentityUri, UserStateId, ItemExcKey, IdentityState)
		VALUES (NewIdentityUri, state_id, NewItemExcKey, NewIdentityState);
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION IdentityStateSet (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewIdentityUri IdentityStates.ItemIdentityUri%TYPE,
	NewIdentityState IdentityStates.IdentityState%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION DeleteIdentitiesMarkers (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
DECLARE
	marker_id INTEGER;
BEGIN
	FOR marker_id IN SELECT id FROM UserMarkers WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey LOOP
		DELETE FROM IdentityMarkers WHERE UserMarkerId=marker_id;
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION DeleteIdentitiesMarkers(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION IdentityMarkerAdd (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewIdentityUri IdentityMarkers.ItemIdentityUri%TYPE,
	NewIdentityMarker IdentityMarkers.IdentityMarker%TYPE
) RETURNS INTEGER AS $$
DECLARE
	marker_id INTEGER;
BEGIN
	FOR marker_id IN SELECT id FROM UserMarkers WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserMarker = NewIdentityMarker LOOP
		INSERT INTO IdentityMarkers (ItemIdentityUri, UserMarkerId, ItemExcKey, IdentityMarker)
		VALUES (NewIdentityUri, marker_id, NewItemExcKey, NewIdentityMarker);
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION IdentityMarkerAdd (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewIdentityUri IdentityMarkers.ItemIdentityUri%TYPE,
	NewIdentityMarker IdentityMarkers.IdentityMarker%TYPE
) TO PUBLIC;
