CREATE OR REPLACE FUNCTION DeleteUserAttributes(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM IdentityMarkers 
	WHERE UserMarkerId IN 
		(SELECT id FROM UserMarkers WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);

	DELETE FROM IdentityStates 
	WHERE UserStateId IN 
		(SELECT id FROM UserStates WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);

	DELETE FROM IdentityRoles
	WHERE UserRoleId IN 
		(SELECT id FROM UserRoles WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);

	DELETE FROM UserMarkers
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

	DELETE FROM UserStates
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

	DELETE FROM UserRoles
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;

	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION DeleteUserAttributes(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;
