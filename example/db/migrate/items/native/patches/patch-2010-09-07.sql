ALTER TABLE Items ADD COLUMN ItemOrigins VARCHAR[];

DROP INDEX IDX_Origin_Item;
CREATE INDEX IDX_Origin_Item ON Items (ItemOriginURI, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemSource;
CREATE INDEX IDX_Origin_ItemSource ON Items (ItemOriginURI, ItemSourceName, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemProvider;
CREATE INDEX IDX_Origin_ItemProvider ON Items (ItemOriginURI, ItemProviderName, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemPhotoCount;
CREATE INDEX IDX_Origin_ItemPhotoCount ON Items (ItemOriginURI, ItemPhotoCount, ItemState, ItemCreationTimestamp) WHERE ItemPhotoCount != 0;

DROP INDEX IDX_Origin_ItemType;
CREATE INDEX IDX_Origin_ItemType ON Items (ItemOriginURI, ItemType, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemVideoCount;
CREATE INDEX IDX_Origin_ItemVideoCount ON Items (ItemOriginURI, ItemVideoCount, ItemState, ItemCreationTimestamp) WHERE ItemVideoCount != 0;

DROP INDEX IDX_Origin_ItemHyperlinkCount;
CREATE INDEX IDX_Origin_ItemHyperlinkCount ON Items (ItemOriginURI, ItemHyperlinkCount, ItemState, ItemCreationTimestamp) WHERE ItemHyperlinkCount != 0;

DROP INDEX IDX_Origin_ItemLikesCount;
CREATE INDEX IDX_Origin_ItemLikesCount ON Items (ItemOriginURI, ItemLikesCount, ItemState, ItemCreationTimestamp) WHERE ItemLikesCount != 0;

DROP INDEX IDX_Origin_ItemRepliesCount;
CREATE INDEX IDX_Origin_ItemRepliesCount ON Items (ItemOriginURI, ItemRepliesCount, ItemState, ItemCreationTimestamp) WHERE ItemRepliesCount != 0;

DROP INDEX IDX_Origin_ItemUserId;
CREATE INDEX IDX_Origin_ItemUserId ON Items (ItemOriginURI, ItemUserId, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemUserEmail;
CREATE INDEX IDX_Origin_ItemUserEmail ON Items (ItemOriginURI, ItemUserEmail, ItemCreationTimestamp, ItemState) WHERE ItemUserEmail IS NOT NULL;

DROP INDEX IDX_Origin_ItemUserIP;
CREATE INDEX IDX_Origin_ItemUserIP ON Items (ItemOriginURI, ItemUserIP, ItemCreationTimestamp, ItemState) WHERE ItemUserIP IS NOT NULL;

DROP INDEX IDX_Parent_Item;
CREATE INDEX IDX_Parent_Item ON Items (ItemParentURI, ItemState, ItemCreationTimestamp);

DROP INDEX IDX_Parent_ItemSource;
CREATE INDEX IDX_Parent_ItemSource ON Items (ItemParentURI, ItemSourceName, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemProvider;
CREATE INDEX IDX_Parent_ItemProvider ON Items (ItemParentURI, ItemProviderName, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemPhotoCount;
CREATE INDEX IDX_Parent_ItemPhotoCount ON Items (ItemParentURI, ItemPhotoCount, ItemState, ItemCreationTimestamp) WHERE ItemPhotoCount != 0;

DROP INDEX IDX_Parent_ItemType;
CREATE INDEX IDX_Parent_ItemType ON Items (ItemParentURI, ItemType, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemVideoCount;
CREATE INDEX IDX_Parent_ItemVideoCount ON Items (ItemParentURI, ItemVideoCount, ItemState, ItemCreationTimestamp) WHERE ItemVideoCount != 0;

DROP INDEX IDX_Parent_ItemHyperlinkCount;
CREATE INDEX IDX_Parent_ItemHyperlinkCount ON Items (ItemParentURI, ItemHyperlinkCount, ItemState, ItemCreationTimestamp) WHERE ItemHyperlinkCount != 0;

DROP INDEX IDX_Parent_ItemLikesCount;
CREATE INDEX IDX_Parent_ItemLikesCount ON Items (ItemParentURI, ItemLikesCount, ItemState, ItemCreationTimestamp) WHERE ItemLikesCount != 0;

DROP INDEX IDX_Parent_ItemRepliesCount;
CREATE INDEX IDX_Parent_ItemRepliesCount ON Items (ItemParentURI, ItemRepliesCount, ItemState, ItemCreationTimestamp) WHERE ItemRepliesCount != 0;

DROP INDEX IDX_Parent_ItemUserId;
CREATE INDEX IDX_Parent_ItemUserId ON Items (ItemParentURI, ItemUserId, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemUserEmail;
CREATE INDEX IDX_Parent_ItemUserEmail ON Items (ItemParentURI, ItemUserEmail, ItemCreationTimestamp, ItemState) WHERE ItemUserEmail IS NOT NULL;

DROP INDEX IDX_Parent_ItemUserIP;
CREATE INDEX IDX_Parent_ItemUserIP ON Items (ItemParentURI, ItemUserIP, ItemCreationTimestamp, ItemState) WHERE ItemUserIP IS NOT NULL;

CREATE OR REPLACE FUNCTION ItemAdd(
	NewItemURI Items.ItemURI%TYPE,
	NewItemURI_Original Items.ItemURI_Original%TYPE,
	NewItemCreationTimestamp Items.ItemCreationTimestamp%TYPE,
	NewItemType Items.ItemType%TYPE,
	NewItemState Items.ItemState%TYPE,
	NewItemOriginURI Items.ItemOriginURI%TYPE,
	NewItemParentURI Items.ItemParentURI%TYPE,
	NewItemSourceName Items.ItemSourceName%TYPE,
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
		ItemSourceName,
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
		ItemMasterVersion,
		ItemOrigins
	) VALUES (
		NewItemURI,
		NewItemURI_Original,
		NewItemCreationTimestamp,
		NewItemType,
		NewItemState,
		NewItemOriginURI,
		NewItemParentURI,
		NewItemSourceName,
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
		NewItemMasterVersion,
		string_to_array(regexp_replace(substring(NewItemOriginURI from 3),E'/[^/]*$',''),'/')
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
	Items.ItemSourceName%TYPE,
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

UPDATE Items SET ItemOrigins=string_to_array(regexp_replace(substring(ItemOriginURI from 3),E'/[^/]*$',''),'/') WHERE ItemOriginURI LIKE '//%';

CREATE INDEX IDX_Parent_Origin ON Items (ItemParentURI, ItemOriginURI);

CREATE INDEX IDX_Origins_Part1 ON Items ((ItemOrigins[1]), ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origins_Part2 ON Items ((ItemOrigins[1]), (ItemOrigins[2]), ItemCreationTimestamp, ItemState);


CREATE OR REPLACE FUNCTION ItemsGetRoots(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, ItemURI_Original Items.ItemURI_Original%TYPE, ItemOriginURI Items.ItemOriginURI%TYPE) AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	roots VARCHAR[][];
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemURI_Original Items.ItemURI_Original%TYPE;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	cnt INT = 0;
	old_cnt INT;
	offset INT = 0;
BEGIN
	root_sql := 'SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemOriginURI ' || RootSelectorFrom || ' ' || RootSelectorWhere || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || RootSelectorLimit;
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE (root_sql || ' OFFSET ' || offset);
		LOOP
			FETCH root_cursor INTO ItemURI, ItemURI_Original, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF (ItemURI != ANY(roots_uris) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				roots := array_cat(roots, ARRAY[[ItemURI, ItemURI_Original, ItemOriginURI]]);
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		offset := offset + RootSelectorLimit;
	END LOOP;
	RETURN QUERY SELECT roots[i][1], roots[i][2], roots[i][3] FROM GENERATE_SERIES(1, ARRAY_UPPER(roots, 1)) i;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRoots(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGet(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
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
	ChildrenSelectorWhereSQL VARCHAR;
	ChildrenSelectorGroupSQL VARCHAR;
BEGIN
	IF (Depth > 0) THEN
		DepthSQL := ' AND R.Depth < ' || Depth;
	ELSE
		DepthSQL := '';
	END IF;
	IF (ChildrenSelectorWhere != 'WHERE ') THEN
		ChildrenSelectorWhereSQL = ChildrenSelectorWhere || ' AND ';
	ELSE
		ChildrenSelectorWhereSQL = ChildrenSelectorWhere;
	END IF;
	IF (ChildrenSelectorGroup != '') THEN
		ChildrenSelectorGroupSQL = ChildrenSelectorGroup || ', R.Depth, R.Path, R.Cnvrs, R.ItemOriginURI';
	ELSE
		ChildrenSelectorGroupSQL = '';
	END IF;
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cycle) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], false, ItemURI_Original as Cnvrs , ItemOriginURI'
		|| ' FROM ItemsGetRoots('
		|| quote_literal(RootSelectorFrom) || ','
		|| quote_literal(RootSelectorWhere) || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemURI = ANY(R.Path), R.Cnvrs, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI '
		|| ChildrenSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || ChildrenSelectorWhereSQL
		|| '(Items.ItemExcKey = ''' || ExcKey 
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
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGet(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

