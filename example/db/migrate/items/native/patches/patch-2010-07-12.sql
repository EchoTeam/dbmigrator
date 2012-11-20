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

GRANT EXECUTE ON FUNCTION UserMarkersGet(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;

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

GRANT EXECUTE ON FUNCTION UserStateGet(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
) TO PUBLIC;

