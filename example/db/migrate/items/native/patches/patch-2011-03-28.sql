CREATE OR REPLACE FUNCTION UserStateSet (
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewIdentityUris VARCHAR[],
	NewUserState UserStates.UserState%TYPE
) RETURNS INTEGER AS $$
DECLARE
	user_state_id INTEGER;
BEGIN
	UPDATE UserStates SET UserState = NewUserState
		WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey
		RETURNING id INTO user_state_id;
	IF NOT found THEN
		INSERT INTO UserStates (ItemUserId, ItemExcKey, UserState)
			VALUES (NewItemUserId, NewItemExcKey, NewUserState)
			RETURNING id INTO user_state_id;
	END IF;

	DELETE FROM IdentityStates WHERE UserStateId = user_state_id AND ItemExcKey = NewItemExcKey;
	FOR i IN 1 .. ARRAY_UPPER(NewIdentityUris, 1) LOOP
		INSERT INTO IdentityStates (ItemIdentityUri, UserStateId, ItemExcKey, IdentityState)
			VALUES (NewIdentityUris[i], user_state_id, NewItemExcKey, NewUserState);
	END LOOP;

	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserStateSet(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewIdentityUris VARCHAR[],
	NewUserState UserStates.UserState%TYPE
) TO PUBLIC;

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

GRANT EXECUTE ON FUNCTION UserStateRenew(
       NewItemUserId UserStates.ItemUserId%TYPE,
       NewItemExcKey UserStates.ItemExcKey%TYPE,
       NewIdentityUris VARCHAR[]
) TO PUBLIC;

/*
-- DROPs should be execeuted after code push for A:4611

DROP FUNCTION UserStateSet(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE,
	NewUserState UserStates.UserState%TYPE
);

DROP FUNCTION IdentityStateSet(
   NewItemUserId UserStates.ItemUserId%TYPE,
   NewItemExcKey UserStates.ItemExcKey%TYPE,
   NewIdentityUri IdentityStates.ItemIdentityUri%TYPE,
   NewIdentityState IdentityStates.IdentityState%TYPE
);

DROP FUNCTION DeleteIdentitiesStates(
   NewItemUserId UserStates.ItemUserId%TYPE,
   NewItemExcKey UserStates.ItemExcKey%TYPE
);

DROP FUNCTION UserStateDelete(
	NewItemUserId UserStates.ItemUserId%TYPE,
	NewItemExcKey UserStates.ItemExcKey%TYPE
);
*/

