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

