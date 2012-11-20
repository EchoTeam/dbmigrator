DROP FUNCTION ItemUpdateAccumulators(
	NewItemURI Items.ItemURI%TYPE,
	NewItemLikesCount Items.ItemLikesCount%TYPE,
	NewItemFlagsCount Items.ItemFlagsCount%TYPE);

CREATE OR REPLACE FUNCTION ItemUpdateAccumulators(
	NewItemURI Items.ItemURI%TYPE,
	NewItemLikesCount Items.ItemLikesCount%TYPE,
	NewItemFlagsCount Items.ItemFlagsCount%TYPE
	) RETURNS INTEGER AS $$
BEGIN
    PERFORM * FROM Items WHERE ItemURI = NewItemURI ORDER BY ItemCreationTimeStamp, ItemURI, ItemOriginURI, ItemParentURI, ItemExcKey FOR UPDATE;
    UPDATE Items SET
        ItemLikesCount = NewItemLikesCount,
        ItemFlagsCount = NewItemFlagsCount
    WHERE ItemURI = NewItemURI;
	RETURN 0;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemUpdateAccumulators(
	Items.ItemURI%TYPE,
	Items.ItemLikesCount%TYPE,
	Items.ItemFlagsCount%TYPE
) TO PUBLIC;
