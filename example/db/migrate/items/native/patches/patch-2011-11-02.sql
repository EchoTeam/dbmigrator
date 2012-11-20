CREATE TYPE ItemsGetRootsCountType AS (
	ItemURI VARCHAR,
	ItemUserId VARCHAR,
	ItemOriginURI VARCHAR
);

CREATE TYPE ItemsGetRootsType AS (
	ItemURI VARCHAR,
	ItemURI_Original VARCHAR,
	ItemOriginURI VARCHAR
);

DROP FUNCTION ItemsGetRoots(VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION ItemsGetRoots(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsType AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	root ItemsGetRootsType%ROWTYPE;
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemURI_Original Items.ItemURI_Original%TYPE;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	cnt INT = 0;
	old_cnt INT;
	cur_offset INT = 0;
	double_limit INT;
BEGIN
	double_limit := RootSelectorLimit * 2;
	root_sql := 'SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemOriginURI ' || RootSelectorFrom || ' ' || RootSelectorWhere || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || double_limit;
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE (root_sql || ' OFFSET ' || cur_offset);
		LOOP
			FETCH root_cursor INTO ItemURI, ItemURI_Original, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				root.ItemURI := ItemURI;
				root.ItemURI_Original := ItemURI_Original;
				root.ItemOriginURI := ItemOriginURI;
				RETURN NEXT root;
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN;
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

DROP FUNCTION ItemsGetRootsMulti(VARCHAR, VARCHAR[][], VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION ItemsGetRootsMulti(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsType AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	root ItemsGetRootsType%ROWTYPE;
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemURI_Original Items.ItemURI_Original%TYPE;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	cnt INT = 0;
	old_cnt INT;
	cur_offset INT = 0;
	double_limit INT;
BEGIN
	double_limit := RootSelectorLimit * 2;
	
	root_sql := ItemsGetRootsMultiSQL(RootSelectorFields, RootSelectorFromWhere, RootSelectorGroup, RootSelectorOrder, double_limit, cur_offset, ExcKey);
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE root_sql;
		LOOP
			FETCH root_cursor INTO ItemURI, ItemURI_Original, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				root.ItemURI := ItemURI;
				root.ItemURI_Original := ItemURI_Original;
				root.ItemOriginURI := ItemOriginURI;
				RETURN NEXT root;
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsMulti(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

DROP FUNCTION ItemsGetRootsCount(VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION ItemsGetRootsCount(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsCountType AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	root ItemsGetRootsCountType%ROWTYPE;
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemUserId Items.ItemUserId%TYPE;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	cnt INT = 0;
	old_cnt INT;
	cur_offset INT = 0;
	double_limit INT;
BEGIN
	double_limit := RootSelectorLimit * 2;
	root_sql := 'SELECT Items.ItemURI, Items.ItemUserId, Items.ItemOriginURI ' || RootSelectorFrom || ' ' || RootSelectorWhere || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || double_limit;
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE (root_sql || ' OFFSET ' || cur_offset);
		LOOP
			FETCH root_cursor INTO ItemURI, ItemUserId, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				root.ItemURI := ItemURI;
				root.ItemUserId := ItemUserId;
				root.ItemOriginURI := ItemOriginURI;
				RETURN NEXT root;
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsCount(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

DROP FUNCTION ItemsGetRootsCountMulti(VARCHAR, VARCHAR[][], VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION ItemsGetRootsCountMulti(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsCountType AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	root ItemsGetRootsCountType%ROWTYPE;
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemUserId Items.ItemUserId%TYPE;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	cnt INT = 0;
	old_cnt INT;
	cur_offset INT = 0;
	double_limit INT;
BEGIN
	double_limit := RootSelectorLimit * 2;
	
	root_sql := ItemsGetRootsCountMultiSQL(RootSelectorFields, RootSelectorFromWhere, RootSelectorGroup, RootSelectorOrder, double_limit, cur_offset, ExcKey);
	LOOP
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE root_sql;
		LOOP
			FETCH root_cursor INTO ItemURI, ItemUserId, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				root.ItemURI := ItemURI;
				root.ItemUserId := ItemUserId;
				root.ItemOriginURI := ItemOriginURI;
				RETURN NEXT root;
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsCountMulti(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

