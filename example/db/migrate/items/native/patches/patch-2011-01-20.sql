CREATE OR REPLACE FUNCTION ItemsIncRepliesCount(
	ItemURIs TEXT[],
	Incs INTEGER[]
) RETURNS INTEGER AS $$
BEGIN
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

-- The function below is no more needed. Can be dropped after release as follows:
-- DROP FUNCTION ItemsIncRepliesCount(TEXT[]);

