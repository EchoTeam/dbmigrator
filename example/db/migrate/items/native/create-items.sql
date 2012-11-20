CREATE TABLE Items (
	ItemURI VARCHAR NOT NULL,
	ItemURI_Original VARCHAR NOT NULL,
	ItemCreationTimestamp TIMESTAMP NOT NULL,
	ItemType VARCHAR NOT NULL,
	ItemState VARCHAR NOT NULL,
	ItemOriginURI VARCHAR NOT NULL,
	ItemParentURI VARCHAR NOT NULL,
	ItemSourceName VARCHAR,
	ItemProviderName VARCHAR NOT NULL,

	ItemPhotoCount INT NOT NULL DEFAULT 0,
	ItemVideoCount INT NOT NULL DEFAULT 0,
	ItemHyperlinkCount INT NOT NULL DEFAULT 0,
	ItemLikesCount INT NOT NULL DEFAULT 0,
	ItemRepliesCount INT NOT NULL DEFAULT 0,
	ItemFlagsCount INT NOT NULL DEFAULT 0,

	ItemUserId VARCHAR,
	ItemUserName VARCHAR,
	ItemUserEmail VARCHAR,
	ItemUserIP INET,

	ItemExcKey VARCHAR NOT NULL,
	ItemMasterVersion BOOLEAN NOT NULL,

	ItemOrigins VARCHAR[],

	PRIMARY KEY (ItemURI, ItemOriginURI, ItemParentURI, ItemExcKey)
) WITHOUT OIDS;

CREATE INDEX IDX_Origin_Item ON Items (ItemOriginURI, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origin_ItemSource ON Items (ItemSourceName, ItemCreationTimestamp, ItemOriginURI, ItemState);

CREATE INDEX IDX_Origin_ItemProvider ON Items (ItemProviderName, ItemCreationTimestamp, ItemOriginURI, ItemState);

CREATE INDEX IDX_Origin_ItemPhotoCount ON Items (ItemPhotoCount, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemPhotoCount != 0;

CREATE INDEX IDX_Origin_ItemType ON Items (ItemType, ItemCreationTimestamp, ItemOriginURI, ItemState);

CREATE INDEX IDX_Origin_ItemVideoCount ON Items (ItemVideoCount, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemVideoCount != 0;

CREATE INDEX IDX_Origin_ItemHyperlinkCount ON Items (ItemHyperlinkCount, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemHyperlinkCount != 0;

CREATE INDEX IDX_Origin_ItemLikesCount ON Items (ItemOriginURI, ItemLikesCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origin_ItemRepliesCount ON Items (ItemOriginURI, ItemRepliesCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origin_ItemFlagsCount ON Items (ItemOriginURI, ItemFlagsCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origin_ItemUserId ON Items (ItemUserId, ItemCreationTimestamp, ItemOriginURI, ItemState);

CREATE INDEX IDX_Origin_ItemUserEmail ON Items (ItemUserEmail, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemUserEmail IS NOT NULL;

CREATE INDEX IDX_Origin_ItemUserIP ON Items (ItemUserIP, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemUserIP IS NOT NULL;

CREATE INDEX IDX_Parent_Item ON Items (ItemParentURI, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Parent_ItemSource ON Items (ItemSourceName, ItemCreationTimestamp, ItemParentURI, ItemState);

CREATE INDEX IDX_Parent_ItemProvider ON Items (ItemProviderName, ItemCreationTimestamp, ItemParentURI, ItemState);

CREATE INDEX IDX_Parent_ItemPhotoCount ON Items (ItemPhotoCount, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemPhotoCount != 0;

CREATE INDEX IDX_Parent_ItemType ON Items (ItemType, ItemCreationTimestamp, ItemParentURI, ItemState);

CREATE INDEX IDX_Parent_ItemVideoCount ON Items (ItemVideoCount, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemVideoCount != 0;

CREATE INDEX IDX_Parent_ItemHyperlinkCount ON Items (ItemHyperlinkCount, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemHyperlinkCount != 0;

CREATE INDEX IDX_Parent_ItemLikesCount ON Items (ItemParentURI, ItemLikesCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Parent_ItemRepliesCount ON Items (ItemParentURI, ItemRepliesCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Parent_ItemFlagsCount ON Items (ItemParentURI, ItemFlagsCount, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Parent_ItemUserId ON Items (ItemUserId, ItemCreationTimestamp, ItemParentURI, ItemState);

CREATE INDEX IDX_Parent_ItemUserEmail ON Items (ItemUserEmail, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemUserEmail IS NOT NULL;

CREATE INDEX IDX_Parent_ItemUserIP ON Items (ItemUserIP, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemUserIP IS NOT NULL;

CREATE INDEX IDX_Parent_Origin ON Items (ItemParentURI, ItemOriginURI);

CREATE INDEX IDX_Origins_Part1 ON Items ((ItemOrigins[1]), ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Origins_Part2 ON Items ((ItemOrigins[1]), (ItemOrigins[2]), ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_ItemURI ON Items (ItemURI);

CREATE INDEX IDX_ItemUserIds ON Items (ItemUserId);

CREATE TABLE ItemRelations (
	ItemURI VARCHAR(255) NOT NULL,
	ItemParentURI VARCHAR(255) NOT NULL,
	Depth SMALLINT NOT NULL,
	PRIMARY KEY (ItemURI, ItemParentURI)
) WITHOUT OIDS;

CREATE INDEX IDX_Rel_ItemParentURI ON ItemRelations (ItemParentURI, Depth);

CREATE TABLE Tags (
	ItemURI VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	ItemTag VARCHAR NOT NULL,
	PRIMARY KEY (ItemURI, ItemExcKey, ItemTag)
);

CREATE INDEX IDX_Tags_Tag ON Tags (ItemTag);

CREATE TABLE Markers (
	ItemURI VARCHAR NOT NULL,
	ItemExcKey VARCHAR NOT NULL,
	ItemMarker VARCHAR NOT NULL,
	PRIMARY KEY (ItemURI, ItemExcKey, ItemMarker)
);

CREATE INDEX IDX_Markers_Marker ON Markers (ItemMarker);

CREATE TABLE ItemExceptions (
	ItemURI VARCHAR NOT NULL,
	ItemExcKey VARCHAR,
	PRIMARY KEY (ItemURI, ItemExcKey)
) WITHOUT OIDS;

GRANT SELECT ON TABLE Items,ItemRelations,Tags,Markers,ItemExceptions TO PUBLIC;

GRANT UPDATE ON TABLE Items TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsIncRepliesCount(
	ItemURIs TEXT[],
	Incs INTEGER[]
) RETURNS INTEGER AS $$
BEGIN
	PERFORM * FROM Items WHERE ItemURI = ANY(ItemURIs) ORDER BY ItemCreationTimeStamp, ItemURI, ItemOriginURI, ItemParentURI, ItemExcKey FOR UPDATE;
	FOR i IN 1 .. ARRAY_UPPER(ItemURIs, 1) LOOP
		UPDATE Items SET ItemRepliesCount = ItemRepliesCount + Incs[i] WHERE ItemURI = ItemURIs[i];
	END LOOP;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsIncRepliesCount(
	TEXT[],
	IncReplies INTEGER[]
) TO PUBLIC;

CREATE OR REPLACE FUNCTION GetUsersItems(
	ItemUserIds TEXT[],
	CountLimit INT
) RETURNS TABLE (ItemURI Items.ItemURI%TYPE) AS $$
BEGIN
	RETURN QUERY (
		SELECT Items.ItemURI FROM Items WHERE Items.ItemUserId = ANY(ItemUserIds) LIMIT CountLimit
	);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION GetUsersItems(
	TEXT[],
	INT
) TO PUBLIC;

CREATE OR REPLACE FUNCTION GetUsersItems(
	ItemUserIds TEXT[],
	CountLimit INT,
	Period VARCHAR
) RETURNS TABLE (ItemURI Items.ItemURI%TYPE) AS $$
BEGIN
	RETURN QUERY (
		SELECT Items.ItemURI FROM Items
		WHERE Items.ItemUserId = ANY(ItemUserIds)
			AND Items.ItemCreationTimestamp >
					(CURRENT_TIMESTAMP - Period::INTERVAL)
		ORDER BY Items.ItemCreationTimestamp DESC
		LIMIT CountLimit
	);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION GetUsersItems(
	TEXT[],
	INT,
	VARCHAR
) TO PUBLIC;

