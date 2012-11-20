DROP TABLE IF EXISTS IdentityRoles;
DROP TABLE IF EXISTS UserRoles;

CREATE TABLE UserRoles (
	id SERIAL,
	ItemUserId VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	UserRole VARCHAR NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (ItemUserId, ItemExcKey, UserRole)
) WITHOUT OIDS;

GRANT SELECT ON TABLE UserRoles TO PUBLIC;

CREATE TABLE IdentityRoles (
	ItemIdentityUri VARCHAR NOT NULL,
	UserRoleId INTEGER,
	ItemExcKey VARCHAR NOT NULL,
	IdentityRole VARCHAR NOT NULL,
	PRIMARY KEY (ItemIdentityUri, ItemExcKey, IdentityRole),
	FOREIGN KEY (UserRoleId) REFERENCES UserRoles (id)
) WITHOUT OIDS;
GRANT SELECT ON TABLE IdentityRoles TO PUBLIC;

CREATE OR REPLACE FUNCTION DeleteIdentitiesRoles (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
) RETURNS INTEGER AS $$
DECLARE
	role_id INTEGER;
BEGIN
	DELETE FROM IdentityRoles WHERE UserRoleId IN 
		(SELECT id FROM UserRoles WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey);
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION DeleteIdentitiesRoles (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION RemoveIdentityRole (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
) RETURNS INTEGER AS $$
DECLARE
	role_id INTEGER;
BEGIN
	DELETE FROM IdentityRoles WHERE UserRoleId IN
		(SELECT id FROM UserRoles WHERE ItemUserId = NewItemUserId AND ItemExcKey = NewItemExcKey AND UserRole = NewIdentityRole);
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION RemoveIdentityRole (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION IdentityRoleAdd (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityUri IdentityRoles.ItemIdentityUri%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
) RETURNS INTEGER AS $$
DECLARE
	role_id INTEGER;
BEGIN
	INSERT INTO IdentityRoles (ItemIdentityUri, UserRoleId, ItemExcKey, IdentityRole)
	SELECT NewIdentityUri, id, NewItemExcKey, NewIdentityRole
		FROM UserRoles
		WHERE 
			ItemUserId = NewItemUserId 
			AND ItemExcKey = NewItemExcKey 
			AND UserRole = NewIdentityRole;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION IdentityRoleAdd (
	NewItemUserId UserRoles.ItemUserId%TYPE,
	NewItemExcKey UserRoles.ItemExcKey%TYPE,
	NewIdentityUri IdentityRoles.ItemIdentityUri%TYPE,
	NewIdentityRole IdentityRoles.IdentityRole%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION DeleteAll(
        ) RETURNS INTEGER AS $$
BEGIN
        TRUNCATE TABLE Markers;
        TRUNCATE TABLE Tags;
        TRUNCATE TABLE ItemRelations;
        TRUNCATE TABLE ItemExceptions;
        TRUNCATE TABLE Items;
        TRUNCATE TABLE IdentityMarkers, UserMarkers;
        TRUNCATE TABLE IdentityStates, UserStates;
        TRUNCATE TABLE IdentityRoles, UserRoles;
        RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION DeleteAll() TO PUBLIC;
