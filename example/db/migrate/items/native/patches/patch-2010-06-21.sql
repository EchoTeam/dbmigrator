CREATE INDEX IDX_Origin_ItemType ON Items (ItemOriginURI, ItemType, ItemState, ItemCreationTimestamp);
CREATE INDEX IDX_Origin_ItemTypeTS ON Items (ItemOriginURI, ItemType, ItemCreationTimestamp, ItemState);

CREATE INDEX IDX_Parent_ItemType ON Items (ItemParentURI, ItemType, ItemState, ItemCreationTimestamp);
CREATE INDEX IDX_Parent_ItemTypeTS ON Items (ItemParentURI, ItemType, ItemCreationTimestamp, ItemState);
