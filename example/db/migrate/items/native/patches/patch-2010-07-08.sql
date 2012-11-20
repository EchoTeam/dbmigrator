CREATE TABLE UserRoles (
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserRole VARCHAR NOT NULL,
	PRIMARY KEY (ItemUserId, ItemExcKey, UserRole)
) WITHOUT OIDS;

GRANT SELECT ON TABLE UserRoles TO PUBLIC;

CREATE OR REPLACE FUNCTION UserRolesAdd (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewUserRoles TEXT
) RETURNS INTEGER AS $$
DECLARE
	NewUserRole UserRoles.UserRole%TYPE;
BEGIN
	FOR NewUserRole IN SELECT REGEXP_SPLIT_TO_TABLE(NewUserRoles,',') LOOP
		BEGIN
            INSERT INTO UserRoles (ItemUserId, ItemExcKey, UserRole)
            VALUES (NewItemUserId, NewItemExcKey, NewUserRole);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserRolesAdd(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE,
	NewUserRoles TEXT
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserRoleRemove (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	UserRoleToDelete UserRoles.UserRole%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM UserRoles
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserRole = UserRoleToDelete;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserRoleRemove (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	UserRoleToDelete UserRoles.UserRole%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION UserRolesDelete (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
BEGIN
	DELETE FROM UserRoles
	WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION UserRolesDelete(
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
) TO PUBLIC;

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

GRANT EXECUTE ON FUNCTION UserRolesGet(
	NewItemUserId UserMarkers.ItemUserId%TYPE,
	NewItemExcKey UserMarkers.ItemExcKey%TYPE
) TO PUBLIC;
