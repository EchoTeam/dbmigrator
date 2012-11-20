-- Changes in tables

CREATE UNIQUE INDEX CONCURRENTLY userstates_itemuserid_itemexckey_key ON userstates(itemuserid, itemexckey);
ALTER TABLE userstates DROP CONSTRAINT userstates_itemuserid_itemexckey_userstate_key;

ALTER TABLE identitystates DROP CONSTRAINT identitystates_pkey;
ALTER TABLE identitystates ADD PRIMARY KEY (ItemIdentityUri, ItemExcKey);

ALTER TABLE IdentityMarkers ADD CONSTRAINT identitymarkers_markerid_fkey FOREIGN KEY (UserMarkerId) REFERENCES UserMarkers(id) ON DELETE CASCADE;
ALTER TABLE IdentityMarkers DROP CONSTRAINT identitymarkers_usermarkerid_fkey;

ALTER TABLE IdentityRoles ADD CONSTRAINT identityroles_roleid_fkey FOREIGN KEY (UserRoleId) REFERENCES UserRoles(id) ON DELETE CASCADE;
ALTER TABLE IdentityRoles DROP CONSTRAINT identityroles_userroleid_fkey;

ALTER TABLE IdentityStates ADD CONSTRAINT identitystates_stateid_fkey FOREIGN KEY (UserStateId) REFERENCES UserStates(id) ON DELETE CASCADE;
ALTER TABLE IdentityStates DROP CONSTRAINT identitystates_userstateid_fkey;


-- New procedures

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

CREATE OR REPLACE FUNCTION UserMarkerRemove (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	UserMarkerToDelete UserMarkers.UserMarker%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM UserMarkers
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserMarker = UserMarkerToDelete;
	RETURN 0;
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

GRANT EXECUTE ON FUNCTION UserMarkerRemove (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	UserMarkerToDelete UserMarkers.UserMarker%TYPE
) TO PUBLIC;

GRANT EXECUTE ON FUNCTION UserDeleteAttributes(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;


-- Dropping old procedures

DROP FUNCTION UserMarkersAdd(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewUserMarkers TEXT
);

DROP FUNCTION UserRolesAdd (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewUserRoles TEXT
);

DROP FUNCTION UserStateRenew(
   NewItemUserId UserStates.ItemUserId%TYPE,
   NewItemExcKey UserStates.ItemExcKey%TYPE,
   NewIdentityUris VARCHAR[]
);

DROP FUNCTION DeleteIdentitiesMarkers (
    NewItemUserId UserStates.ItemUserId%TYPE,
    NewItemExcKey UserStates.ItemExcKey%TYPE
);

DROP FUNCTION DeleteIdentitiesRoles (
    NewItemUserId UserRoles.ItemUserId%TYPE,
    NewItemExcKey UserRoles.ItemExcKey%TYPE
);

DROP FUNCTION IdentityRoleAdd (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityUri IdentityRoles.ItemIdentityUri%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
);

DROP FUNCTION IdentityMarkerAdd (
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewIdentityUri IdentityMarkers.ItemIdentityUri%TYPE,
	NewIdentityMarker IdentityMarkers.IdentityMarker%TYPE
);

DROP FUNCTION RemoveIdentityRole (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
);

DROP FUNCTION UserMarkersDelete(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
);

DROP FUNCTION UserRolesDelete(
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
);

DROP FUNCTION DeleteUserAttributes(
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
);
