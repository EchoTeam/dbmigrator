DROP INDEX IDX_Origin_ItemSource;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemSource ON Items (ItemSourceName, ItemCreationTimestamp, ItemOriginURI, ItemState);

DROP INDEX IDX_Origin_ItemProvider;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemProvider ON Items (ItemProviderName, ItemCreationTimestamp, ItemOriginURI, ItemState);

DROP INDEX IDX_Origin_ItemType;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemType ON Items (ItemType, ItemCreationTimestamp, ItemOriginURI, ItemState);

DROP INDEX IDX_Origin_ItemUserId;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemUserId ON Items (ItemUserId, ItemCreationTimestamp, ItemOriginURI, ItemState);

DROP INDEX IDX_Origin_ItemUserEmail;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemUserEmail ON Items (ItemUserEmail, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemUserEmail IS NOT NULL;

DROP INDEX IDX_Origin_ItemUserIP;
CREATE INDEX CONCURRENTLY IDX_Origin_ItemUserIP ON Items (ItemUserIP, ItemCreationTimestamp, ItemOriginURI, ItemState) WHERE ItemUserIP IS NOT NULL;

DROP INDEX IDX_Parent_ItemSource;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemSource ON Items (ItemSourceName, ItemCreationTimestamp, ItemParentURI, ItemState);

DROP INDEX IDX_Parent_ItemProvider;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemProvider ON Items (ItemProviderName, ItemCreationTimestamp, ItemParentURI, ItemState);

DROP INDEX IDX_Parent_ItemType;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemType ON Items (ItemType, ItemCreationTimestamp, ItemParentURI, ItemState);

DROP INDEX IDX_Parent_ItemUserId;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemUserId ON Items (ItemUserId, ItemCreationTimestamp, ItemParentURI, ItemState);

DROP INDEX IDX_Parent_ItemUserEmail;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemUserEmail ON Items (ItemUserEmail, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemUserEmail IS NOT NULL;

DROP INDEX IDX_Parent_ItemUserIP;
CREATE INDEX CONCURRENTLY IDX_Parent_ItemUserIP ON Items (ItemUserIP, ItemCreationTimestamp, ItemParentURI, ItemState) WHERE ItemUserIP IS NOT NULL;

