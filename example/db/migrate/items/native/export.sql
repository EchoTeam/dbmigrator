-- CREATE TABLE ItemsExport (ItemURI VARCHAR NOT NULL PRIMARY KEY) WITHOUT OIDS;
-- GRANT SELECT, INSERT, DELETE, TRUNCATE ON ItemsExport TO PUBLIC;

----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ExportUsers(
	ExportExcKey VARCHAR
) RETURNS INTEGER AS $$
DECLARE
	SQL VARCHAR;
	PREFIX VARCHAR;
BEGIN
	BEGIN
		PREFIX := '/tmp/' || ExportExcKey || '__';

		-- Identity Markers
		SQL := 'COPY (SELECT * FROM IdentityMarkers WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'identitymarkers.copy''';
		EXECUTE SQL;

		-- Identity Roles
		SQL := 'COPY (SELECT * FROM IdentityRoles WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'identityroles.copy''';
		EXECUTE SQL;

		-- Identity States
		SQL := 'COPY (SELECT * FROM IdentityStates WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'identitystates.copy''';
		EXECUTE SQL;

		-- User Markers
		SQL := 'COPY (SELECT * FROM UserMarkers WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'usermarkers.copy''';
		EXECUTE SQL;

		-- User Roles
		SQL := 'COPY (SELECT * FROM UserRoles WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'userroles.copy''';
		EXECUTE SQL;

		-- User States
		SQL := 'COPY (SELECT * FROM UserStates WHERE ItemExcKey = ' || quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'userstates.copy''';
		EXECUTE SQL;
	END;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ExportUsers(
	ExportExcKey VARCHAR
) TO PUBLIC;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ExportItems(
	ExportExcKey VARCHAR,
	Domain VARCHAR,
	DataType VARCHAR
) RETURNS INTEGER AS $$
DECLARE
	SQL VARCHAR;
	PREFIX VARCHAR;
	ItemsWHERE VARCHAR;
BEGIN
	BEGIN
		PREFIX := '/tmp/' || ExportExcKey || '_' || DataType || '_' || Domain || '_export_';

        TRUNCATE TABLE ItemsExport;
		IF (DataType = 'dump') THEN
		    INSERT INTO ItemsExport SELECT DISTINCT(ItemURI) FROM Items WHERE itemorigins[1] = Domain;
            ItemsWHERE := 'WHERE itemorigins[1] = ' || quote_literal(Domain);
		ELSE IF (DataType = 'diff') THEN
            INSERT INTO ItemsExport SELECT ItemURI FROM export_diff_items;
            ItemsWHERE := 'WHERE ItemOrigins[1]=ANY(export_domains())';
		END IF;
		END IF;

		-- Items
		SQL := 'COPY (SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemCreationTimestamp, Items.ItemType, Items.ItemState, Items.ItemOriginURI, Items.ItemParentURI, Items.ItemSourceName, Items.ItemProviderName, Items.ItemPhotoCount, Items.ItemVideoCount, Items.ItemHyperlinkCount, Items.ItemLikesCount, Items.ItemRepliesCount, CASE WHEN Items.ItemFlagsCount IS NULL THEN 0 ELSE Items.ItemFlagsCount END, Items.ItemUserId, Items.ItemUserName, Items.ItemUserEmail, Items.ItemUserIP, Items.ItemExcKey, Items.ItemMasterVersion, Items.ItemOrigins FROM Items JOIN ItemsExport ON ItemsExport.ItemURI = Items.ItemURI ' || ItemsWHERE || ') TO ''' || PREFIX || 'items.copy''';
		EXECUTE SQL;

		-- Markers
		SQL := 'COPY (SELECT Markers.ItemURI, Markers.ItemExcKey, Markers.ItemMarker FROM Markers JOIN ItemsExport ON ItemsExport.ItemURI = Markers.ItemURI) TO ''' || PREFIX || 'markers.copy''';
		EXECUTE SQL;

		-- Tags
		SQL := 'COPY (SELECT Tags.ItemURI, Tags.ItemExcKey, Tags.ItemTag FROM Tags JOIN ItemsExport ON ItemsExport.ItemURI = Tags.ItemURI) TO ''' || PREFIX || 'tags.copy''';
		EXECUTE SQL;

		-- ItemExceptions
		SQL := 'COPY (SELECT ItemExceptions.ItemURI, ItemExceptions.ItemExcKey FROM ItemExceptions JOIN ItemsExport ON ItemsExport.ItemURI = ItemExceptions.ItemURI WHERE ItemExcKey = '
			|| quote_literal(ExportExcKey) || ') TO ''' || PREFIX || 'itemexceptions.copy''';
		EXECUTE SQL;
	END;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ExportItems(
	ExportExcKey VARCHAR,
	Domain VARCHAR,
	DataType VARCHAR
) TO PUBLIC;

----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ExportDiffItems(
	ExportExcKey VARCHAR
) RETURNS VOID AS $$
DECLARE
	SQL VARCHAR;
	PREFIX VARCHAR;
BEGIN
	PREFIX := '/tmp/' || ExportExcKey || '__';
	SQL := 'COPY (SELECT ItemURI, ctime FROM export_diff_items) TO ''' || PREFIX || 'export_diff_items.copy''';
	EXECUTE SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ExportDiffItems(
	ExportExcKey VARCHAR
) TO PUBLIC;

