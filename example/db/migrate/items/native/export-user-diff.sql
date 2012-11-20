/*
CREATE TABLE export_diff_identities (
    IdentityURI VARCHAR(255) NOT NULL,
    PRIMARY KEY (IdentityURI)
) WITHOUT OIDS;

CREATE TABLE export_diff_users (
    UserURI VARCHAR(255) NOT NULL,
    PRIMARY KEY (UserURI)
) WITHOUT OIDS;

CREATE OR REPLACE FUNCTION process_export_diff_identities() RETURNS TRIGGER AS $$
DECLARE
    ExcKey VARCHAR;
    URI VARCHAR;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        URI := OLD.ItemIdentityUri;
        ExcKey := OLD.itemexckey;
    ELSE
        URI := NEW.ItemIdentityUri;
        ExcKey := NEW.itemexckey;
    END IF;
    IF (ExcKey=export_exckey()) THEN
        BEGIN
            INSERT INTO export_diff_identities VALUES (URI);
            EXCEPTION WHEN UNIQUE_VIOLATION THEN
        END
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_export_diff_users() RETURNS TRIGGER AS $$
DECLARE
    ExcKey VARCHAR;
    UserId VARCHAR;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UserId := OLD.ItemUserId;
        ExcKey := OLD.itemexckey;
    ELSE
        UserId := NEW.ItemUserId;
        ExcKey := NEW.itemexckey;
    END IF;
    IF (ExcKey=export_exckey()) THEN
        BEGIN
            INSERT INTO export_diff_users VALUES (UserId);
            EXCEPTION WHEN UNIQUE_VIOLATION THEN
        END
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER export_diff_identitymarkers
AFTER INSERT OR UPDATE OR DELETE ON identitymarkers
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_identities();

CREATE TRIGGER export_diff_identityroles
AFTER INSERT OR UPDATE OR DELETE ON identityroles
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_identities();

CREATE TRIGGER export_diff_identitystates
AFTER INSERT OR UPDATE OR DELETE ON identitystates
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_identities();

CREATE TRIGGER export_diff_usermarkers
AFTER INSERT OR UPDATE OR DELETE ON usermarkers
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_users();

CREATE TRIGGER export_diff_userroles
AFTER INSERT OR UPDATE OR DELETE ON userroles
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_users();

CREATE TRIGGER export_diff_userstates
AFTER INSERT OR UPDATE OR DELETE ON userstates
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_users();

ALTER TABLE identitymarkers DISABLE TRIGGER export_diff_identitymarkers;
ALTER TABLE identityroles DISABLE TRIGGER export_diff_identityroles;
ALTER TABLE identitystates DISABLE TRIGGER export_diff_identitystates;
ALTER TABLE usermarkers DISABLE TRIGGER export_diff_usermarkers;
ALTER TABLE userroles DISABLE TRIGGER export_diff_userroles;
ALTER TABLE userstates DISABLE TRIGGER export_diff_userstates;
*/
