ALTER TABLE Items ADD ItemExcKey VARCHAR;
ALTER TABLE Items ADD ItemMasterVersion BOOLEAN;

UPDATE Items SET ItemExcKey = '', ItemMasterVersion = 'true';

ALTER TABLE Items ALTER COLUMN ItemExcKey SET NOT NULL;
ALTER TABLE Items ALTER COLUMN ItemMasterVersion SET NOT NULL;

ALTER TABLE Items DROP CONSTRAINT Items_PKey;
ALTER TABLE Items ADD PRIMARY KEY (ItemURI, ItemOriginURI, ItemParentURI, ItemExcKey);

ALTER TABLE Tags ADD ItemExcKey VARCHAR;
UPDATE Tags SET ItemExcKey = '';
ALTER TABLE Tags ALTER COLUMN ItemExcKey SET NOT NULL;
ALTER TABLE Tags DROP CONSTRAINT Tags_PKey;
ALTER TABLE Tags ADD PRIMARY KEY (ItemURI, ItemExcKey, ItemTag);

ALTER TABLE Markers ADD ItemExcKey VARCHAR;
UPDATE Markers SET ItemExcKey = '';
ALTER TABLE Markers ALTER COLUMN ItemExcKey SET NOT NULL;
ALTER TABLE Markers DROP CONSTRAINT Markers_PKey;
ALTER TABLE Markers ADD PRIMARY KEY (ItemURI, ItemExcKey, ItemMarker);

CREATE TABLE ItemExceptions (
	ItemURI VARCHAR NOT NULL,
	ItemExcKey VARCHAR,
	PRIMARY KEY (ItemURI, ItemExcKey)
) WITHOUT OIDS;

GRANT SELECT ON TABLE Items,ItemRelations,Tags,Markers,ItemExceptions TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemDelete(
	NewItemURI Items.ItemURI%TYPE
	) RETURNS INTEGER AS $$
DECLARE
	SQL VARCHAR;
	DepthSQL VARCHAR;
BEGIN
	DELETE FROM Tags WHERE ItemURI = NewItemURI;
	DELETE FROM ItemRelations WHERE ItemURI = NewItemURI OR ItemParentURI = NewItemURI;
	DELETE FROM ItemExceptions WHERE ItemURI = NewItemURI;
	DELETE FROM Items WHERE ItemURI = NewItemURI;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemDelete(
	Items.ItemURI%TYPE
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGet(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrderLimit VARCHAR,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrderLimit VARCHAR,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, Cnvrs Items.ItemURI_Original%TYPE) AS $$
DECLARE
	SQL VARCHAR;
	DepthSQL VARCHAR;
	ChildrenSelectorGroupSQL VARCHAR;
BEGIN
	SET ENABLE_HASHJOIN = OFF;
	SET ENABLE_MERGEJOIN = OFF;
	SET ENABLE_SEQSCAN = OFF;
	IF (Depth > 0) THEN
		DepthSQL := ' AND R.Depth < ' || Depth;
	ELSE
		DepthSQL := '';
	END IF;
	IF (ChildrenSelectorGroup != '') THEN
		ChildrenSelectorGroupSQL = ChildrenSelectorGroup || ', R.Depth, R.Path, R.Cnvrs, R.ItemOriginURI';
	ELSE
		ChildrenSelectorGroupSQL = '';
	END IF;
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cycle) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], false, ItemURI_Original as Cnvrs , ItemOriginURI'
		|| ' FROM ( SELECT Items.ItemURI,Items.ItemURI_Original,Items.ItemOriginURI ' 
		|| RootSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || RootSelectorWhere 
		|| ' AND (Items.ItemExcKey = ''' || ExcKey 
		|| ''' OR (Items.ItemMasterVersion AND ItemExceptions.ItemExcKey IS NULL)) ' 
		|| RootSelectorGroup || ' ' || RootSelectorOrderLimit 
		|| ' ) AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemURI = ANY(R.Path), R.Cnvrs, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI '
		|| ChildrenSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || ChildrenSelectorWhere
		|| ' AND (Items.ItemExcKey = ''' || ExcKey 
		|| ''' OR (Items.ItemMasterVersion AND ItemExceptions.ItemExcKey IS NULL)) ' 
		|| ' ) AS Items '
		|| ' INNER JOIN ITMS R ON Items.ItemParentURI = R.ItemURI '
		|| ' AND Items.ItemOriginURI = R.ItemOriginURI '
		|| ' AND NOT R.Cycle ' || DepthSQL
		|| ' ' || ChildrenSelectorGroupSQL
		|| ' ' || ChildrenSelectorOrderLimit
		|| ' ) AS T)'
		|| ' SELECT ItemURI, Cnvrs FROM ITMS';
	RETURN QUERY EXECUTE SQL;
	SET ENABLE_HASHJOIN = ON;
	SET ENABLE_MERGEJOIN = ON;
	SET ENABLE_SEQSCAN = ON;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGet(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemAdd(
	NewItemURI Items.ItemURI%TYPE,
	NewItemURI_Original Items.ItemURI_Original%TYPE,
	NewItemCreationTimestamp Items.ItemCreationTimestamp%TYPE,
	NewItemType Items.ItemType%TYPE,
	NewItemState Items.ItemState%TYPE,
	NewItemOriginURI Items.ItemOriginURI%TYPE,
	NewItemParentURI Items.ItemParentURI%TYPE,
	NewItemProviderName Items.ItemProviderName%TYPE,
	NewItemPhotoCount Items.ItemPhotoCount%TYPE,
	NewItemVideoCount Items.ItemVideoCount%TYPE,
	NewItemHyperlinkCount Items.ItemHyperlinkCount%TYPE,
	NewItemLikesCount Items.ItemLikesCount%TYPE,
	NewItemRepliesCount Items.ItemRepliesCount%TYPE,
	NewItemUserId Items.ItemUserId%TYPE,
	NewItemUserName Items.ItemUserName%TYPE,
	NewItemUserEmail Items.ItemUserEmail%TYPE,
	NewItemUserIP Items.ItemUserIP%TYPE,
	NewItemTags TEXT,
	NewItemMarkers TEXT,
	NewItemExcKey Items.ItemExcKey%TYPE,
	NewItemMasterVersion Items.ItemMasterVersion%TYPE
	) RETURNS INTEGER AS $$
DECLARE
	NewTag Tags.ItemTag%TYPE;
	NewMarker Markers.ItemMarker%TYPE;
BEGIN
	FOR NewTag IN SELECT REGEXP_SPLIT_TO_TABLE(NewItemTags,',') LOOP
		BEGIN
			INSERT INTO Tags (ItemURI, ItemExcKey, ItemTag) VALUES (NewItemURI, NewItemExcKey, NewTag);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END LOOP;
	FOR NewMarker IN SELECT REGEXP_SPLIT_TO_TABLE(NewItemMarkers,',') LOOP
		BEGIN
			INSERT INTO Markers (ItemURI, ItemExcKey, ItemMarker) VALUES (NewItemURI, NewItemExcKey, NewMarker);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END LOOP;
	INSERT INTO Items (
		ItemURI,
		ItemURI_Original,
		ItemCreationTimestamp,
		ItemType,
		ItemState,
		ItemOriginURI,
		ItemParentURI,
		ItemProviderName,
		ItemPhotoCount,
		ItemVideoCount,
		ItemHyperlinkCount,
		ItemLikesCount,
		ItemRepliesCount,
		ItemUserId,
		ItemUserName,
		ItemUserEmail,
		ItemUserIP,
		ItemExcKey,
		ItemMasterVersion
	) VALUES (
		NewItemURI,
		NewItemURI_Original,
		NewItemCreationTimestamp,
		NewItemType,
		NewItemState,
		NewItemOriginURI,
		NewItemParentURI,
		NewItemProviderName,
		NewItemPhotoCount,
		NewItemVideoCount,
		NewItemHyperlinkCount,
		NewItemLikesCount,
		NewItemRepliesCount,
		NewItemUserId,
		NewItemUserName,
		NewItemUserEmail,
		NewItemUserIP,
		NewItemExcKey,
		NewItemMasterVersion
	);
	IF NewItemOriginURI <> NewItemParentURI THEN
		INSERT INTO ItemRelations (ItemURI, ItemParentURI, Depth)
		SELECT NewItemURI, T.ItemParentURI, T.Depth + 1
		FROM ItemRelations T LEFT JOIN ItemRelations T2
		ON T.ItemParentURI = T2.ItemParentURI
			AND T2.ItemURI = NewItemURI
		WHERE T.ItemURI = NewItemParentURI
			AND T.ItemParentURI <> NewItemURI
			AND T2.ItemURI IS NULL;
		BEGIN
			INSERT INTO ItemRelations (ItemURI, ItemParentURI, Depth)
			VALUES (NewItemURI, NewItemParentURI, 1);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END IF;
	IF NOT(NewItemMasterVersion) THEN
		BEGIN
			INSERT INTO ItemExceptions (ItemURI, ItemExcKey)
			VALUES (NewItemURI, NewItemExcKey);
		EXCEPTION
			WHEN UNIQUE_VIOLATION THEN
		END;
	END IF;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemAdd(
	Items.ItemURI%TYPE,
	Items.ItemURI_Original%TYPE,
	Items.ItemCreationTimestamp%TYPE,
	Items.ItemType%TYPE,
	Items.ItemState%TYPE,
	Items.ItemOriginURI%TYPE,
	Items.ItemParentURI%TYPE,
	Items.ItemProviderName%TYPE,
	Items.ItemPhotoCount%TYPE,
	Items.ItemVideoCount%TYPE,
	Items.ItemHyperlinkCount%TYPE,
	Items.ItemLikesCount%TYPE,
	Items.ItemRepliesCount%TYPE,
	Items.ItemUserId%TYPE,
	Items.ItemUserName%TYPE,
	Items.ItemUserEmail%TYPE,
	Items.ItemUserIP%TYPE,
	TEXT,
	TEXT,
	Items.ItemExcKey%TYPE,
	Items.ItemMasterVersion%TYPE
) TO PUBLIC;


