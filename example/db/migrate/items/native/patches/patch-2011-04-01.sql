CREATE OR REPLACE FUNCTION UserStateRenew (
       NewItemUserId UserStates.ItemUserId%TYPE,
       NewItemExcKey UserStates.ItemExcKey%TYPE,
       NewIdentityUris VARCHAR[]
) RETURNS INTEGER AS $$
DECLARE
       state VARCHAR;
BEGIN
	state := (SELECT UserStateGet(NewItemUserId, NewItemExcKey));
	IF state IS NOT NULL THEN
		PERFORM UserStateSet(NewItemUserId, NewItemExcKey, NewIdentityUris, state);
	END IF;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;
