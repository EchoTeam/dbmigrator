CREATE OR REPLACE FUNCTION UserMarkersAdd (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewUserMarkers TEXT
) RETURNS INTEGER AS $$
DECLARE
	NewMarker UserMarkers.UserMarker%TYPE;
BEGIN
	FOR NewMarker IN SELECT REGEXP_SPLIT_TO_TABLE(NewUserMarkers,',') LOOP
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
