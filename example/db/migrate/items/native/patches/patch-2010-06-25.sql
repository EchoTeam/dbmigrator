CREATE TABLE UserMarkers (
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserMarker VARCHAR NOT NULL,
	PRIMARY KEY (ItemUserId, ItemExcKey, UserMarker)
) WITHOUT OIDS;

GRANT SELECT ON TABLE UserMarkers TO PUBLIC;

CREATE TABLE UserStates (
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserState VARCHAR NOT NULL,
	PRIMARY KEY (ItemUserId, ItemExcKey, UserState)
) WITHOUT OIDS;

GRANT SELECT ON TABLE UserStates TO PUBLIC;

CREATE OR REPLACE FUNCTION UserMarkersAdd (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewUserMarkers TEXT
) RETURNS INTEGER AS $$
DECLARE
	NewMarker UserMarkers.UserMarker%TYPE;
BEGIN
	FOR NewMarker IN SELECT REGEXP_SPLIT_TO_TABLE(NewUserMarker,',') LOOP
		BEGIN
			INSERT INTO UserMarkers (ItemUserId, ItemExcKey, UserMarker) VALUES (NewItemUserId, NewItemExcKey, NewMarker);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserMarkersAdd(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewUserMarkers TEXT
) TO PUBLIC;


CREATE OR REPLACE FUNCTION UserMarkersDelete (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM UserMarkers
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserMarkersDelete(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserStateSet (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewUserState UserStates.UserState%TYPE
) RETURNS INTEGER AS $$
BEGIN
	UPDATE UserStates SET UserState = NewUserState
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
	IF found THEN
		RETURN 0;
	END IF;
	BEGIN
		INSERT INTO UserStates (ItemUserId, ItemExcKey, UserState)
		VALUES (NewItemUserId, NewItemExcKey, NewUserState);
	EXCEPTION
		WHEN UNIQUE_VIOLATION THEN
	END;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserStateSet(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewUserState UserStates.UserState%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserStateDelete (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM UserStates
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserStateDelete(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

