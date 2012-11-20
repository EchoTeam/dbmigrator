ALTER TABLE Items ADD ItemSourceName VARCHAR;

CREATE INDEX IDX_Origin_ItemSource ON Items (ItemOriginURI, ItemSourceName, ItemState, ItemCreationTimestamp);
CREATE INDEX IDX_Origin_ItemSourceTS ON Items (ItemOriginURI, ItemSourceName, ItemCreationTimestamp, ItemState);
CREATE INDEX IDX_Parent_ItemSource ON Items (ItemParentURI, ItemSourceName, ItemState, ItemCreationTimestamp);
CREATE INDEX IDX_Parent_ItemSourceTS ON Items (ItemParentURI, ItemSourceName, ItemCreationTimestamp, ItemState);

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
		ItemMasterVersion
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
