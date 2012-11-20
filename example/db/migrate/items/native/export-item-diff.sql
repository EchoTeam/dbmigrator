CREATE OR REPLACE FUNCTION export_domains() RETURNS VARCHAR[] AS $$
BEGIN
    RETURN '{"domain.com","domain1.com"}';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION export_exckey() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'exckey';
END;
$$ LANGUAGE plpgsql;

-----------------

CREATE TABLE export_diff_items (
    ItemURI VARCHAR(255) NOT NULL,
    ctime timestamp without time zone,
    PRIMARY KEY (ItemURI)
) WITHOUT OIDS;

CREATE OR REPLACE FUNCTION ExportDiffInit() RETURNS VOID AS $$
BEGIN
    DELETE FROM Items USING export_diff_items
        WHERE Items.ItemURI = export_diff_items.ItemURI;
    DELETE FROM ItemExceptions USING export_diff_items
        WHERE ItemExceptions.ItemURI = export_diff_items.ItemURI;
    DELETE FROM Markers USING export_diff_items
        WHERE Markers.ItemURI = export_diff_items.ItemURI;
    DELETE FROM Tags USING export_diff_items
        WHERE Tags.ItemURI = export_diff_items.ItemURI;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION ExportDiffInit() TO PUBLIC;

-----------------

CREATE OR REPLACE FUNCTION save_export_diff_itemuri(
    NewItemURI export_diff_items.ItemURI%TYPE
) RETURNS VOID AS $$
BEGIN
    INSERT INTO export_diff_items VALUES (NewItemURI, NOW());
    EXCEPTION WHEN UNIQUE_VIOLATION THEN
        UPDATE export_diff_items SET ctime = NOW() WHERE ItemURI = NewItemURI;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_export_diff_items() RETURNS TRIGGER AS $$
DECLARE
    Domain VARCHAR;
    URI VARCHAR;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        Domain := OLD.ItemOrigins[1];
        URI := OLD.ItemURI;
    ELSE
        Domain := NEW.ItemOrigins[1];
        URI := NEW.ItemURI;
    END IF;
    IF (Domain=ANY(export_domains())) THEN
        PERFORM save_export_diff_itemuri(URI);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_export_diff_item_relations() RETURNS TRIGGER AS $$
DECLARE
    URI VARCHAR;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        URI := OLD.ItemURI;
    ELSE
        URI := NEW.ItemURI;
    END IF;
    PERFORM * FROM Items WHERE ItemURI=URI AND ItemOrigins[1]=ANY(export_domains());
    IF FOUND THEN
        PERFORM save_export_diff_itemuri(URI);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER export_diff_items
AFTER INSERT OR UPDATE OR DELETE ON items
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_items();

CREATE TRIGGER export_diff_markers
AFTER INSERT OR UPDATE OR DELETE ON markers
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_item_relations();

CREATE TRIGGER export_diff_tags
AFTER INSERT OR UPDATE OR DELETE ON tags
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_item_relations();

CREATE TRIGGER export_diff_itemexceptions
AFTER INSERT OR UPDATE OR DELETE ON itemexceptions
FOR EACH ROW EXECUTE PROCEDURE process_export_diff_item_relations();

ALTER TABLE items DISABLE TRIGGER export_diff_items;
ALTER TABLE markers DISABLE TRIGGER export_diff_markers;
ALTER TABLE tags DISABLE TRIGGER export_diff_tags;
ALTER TABLE itemexceptions DISABLE TRIGGER export_diff_itemexceptions;
