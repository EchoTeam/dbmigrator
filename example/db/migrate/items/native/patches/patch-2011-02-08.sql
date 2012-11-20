CREATE TABLE ItemsExport (ItemURI VARCHAR NOT NULL PRIMARY KEY) WITHOUT OIDS;
GRANT SELECT, INSERT, DELETE, TRUNCATE ON ItemsExport TO PUBLIC;

----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ExportUsers(
	ExportExcKey VARCHAR
) RETURNS INTEGER AS $$
DECLARE
	SQL VARCHAR;
	PREFIX VARCHAR;
BEGIN
	BEGIN
		PREFIX := '/tmp/' || ExportExcKey || '_export_';

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
	Since TIMESTAMP
) RETURNS INTEGER AS $$
DECLARE
	SQL VARCHAR;
	PREFIX VARCHAR;
BEGIN
	BEGIN
		PREFIX := '/tmp/' || ExportExcKey || '_' || Domain || '_' || to_char(Since, 'YYYYMMDDHHMMSSMS') || '_export_';

		TRUNCATE TABLE ItemsExport;
		INSERT INTO ItemsExport SELECT DISTINCT(ItemURI) FROM Items WHERE itemorigins[1] = Domain AND ItemCreationTimestamp > Since;

		-- Items
		SQL := 'COPY (SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemCreationTimestamp, Items.ItemType, Items.ItemState, Items.ItemOriginURI, Items.ItemParentURI, Items.ItemSourceName, Items.ItemProviderName, Items.ItemPhotoCount, Items.ItemVideoCount, Items.ItemHyperlinkCount, Items.ItemLikesCount, Items.ItemRepliesCount, Items.ItemFlagsCount, Items.ItemUserId, Items.ItemUserName, Items.ItemUserEmail, Items.ItemUserIP, Items.ItemExcKey, Items.ItemMasterVersion, Items.ItemOrigins FROM Items JOIN ItemsExport ON ItemsExport.ItemURI = Items.ItemURI WHERE itemorigins[1] = '
			|| quote_literal(Domain) || ') TO ''' || PREFIX || 'items.copy''';
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

		-- ItemRelations
		SQL := 'COPY (SELECT ItemRelations.ItemURI, ItemRelations.ItemParentURI, ItemRelations.Depth FROM ItemRelations JOIN ItemsExport ON ItemsExport.ItemURI = ItemRelations.ItemURI) TO ''' || PREFIX || 'itemrelations.copy''';
		EXECUTE SQL;
	END;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ExportItems(
	ExportExcKey VARCHAR,
	Domain VARCHAR,
	Since TIMESTAMP
) TO PUBLIC;
