DROP INDEX IDX_Origin_ItemLikesCount;

CREATE INDEX CONCURRENTLY IDX_Origin_ItemLikesCount ON Items (ItemOriginURI, ItemLikesCount, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Origin_ItemRepliesCount;

CREATE INDEX CONCURRENTLY IDX_Origin_ItemRepliesCount ON Items (ItemOriginURI, ItemRepliesCount, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemLikesCount;

CREATE INDEX CONCURRENTLY IDX_Parent_ItemLikesCount ON Items (ItemParentURI, ItemLikesCount, ItemCreationTimestamp, ItemState);

DROP INDEX IDX_Parent_ItemRepliesCount;

CREATE INDEX CONCURRENTLY IDX_Parent_ItemRepliesCount ON Items (ItemParentURI, ItemRepliesCount, ItemCreationTimestamp, ItemState);

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
	double_limit INT;
BEGIN
	double_limit := RootSelectorLimit * 2;
	root_sql := 'SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemOriginURI ' || RootSelectorFrom || ' ' || RootSelectorWhere || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || double_limit;
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE (root_sql || ' OFFSET ' || offset);
		LOOP
			FETCH root_cursor INTO ItemURI, ItemURI_Original, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				roots := array_cat(roots, ARRAY[[ItemURI, ItemURI_Original, ItemOriginURI]]);
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		offset := offset + double_limit;
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

