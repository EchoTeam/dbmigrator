CREATE OR REPLACE FUNCTION ItemsGetRootsCount(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, ItemUserId Items.ItemUserId%TYPE, ItemOriginURI Items.ItemOriginURI%TYPE) AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	roots VARCHAR[][];
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
				roots := array_cat(roots, ARRAY[[ItemURI, ItemUserId, ItemOriginURI]]);
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN QUERY SELECT roots[i][1], roots[i][2], roots[i][3] FROM GENERATE_SERIES(1, ARRAY_UPPER(roots, 1)) i;
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

CREATE OR REPLACE FUNCTION ItemsGetCount(
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
	) RETURNS TABLE (ItemUserId Items.ItemUserId%TYPE) AS $$
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
		ChildrenSelectorGroupSQL = ChildrenSelectorGroup || ', R.Depth, R.Path, R.ItemUserId, R.ItemOriginURI';
	ELSE
		ChildrenSelectorGroupSQL = '';
	END IF;
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cycle) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], false, ItemUserId, ItemOriginURI'
		|| ' FROM ItemsGetRootsCount('
		|| quote_literal(RootSelectorFrom) || ','
		|| quote_literal(RootSelectorWhere) || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemURI = ANY(R.Path), Items.ItemUserId, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI, Items.ItemUserId '
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
		|| ' SELECT ItemUserId FROM ITMS';
	RETURN QUERY EXECUTE SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetCount(
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

CREATE OR REPLACE FUNCTION ItemsGetRootsCountMultiSQL(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	RootSelectorOffset INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	RootMultiSQL VARCHAR := 'SELECT Items.ItemURI, Items.ItemUserId, Items.ItemOriginURI FROM (';
	RootSelectorFieldsSQL VARCHAR;
	FromWhereArrayLen INT;
	UnionPart VARCHAR := '';
BEGIN
	IF (RootSelectorFields != '') THEN
		RootSelectorFieldsSQL := ', ' || RootSelectorFields || ' ';
	ELSE
		RootSelectorFieldsSQL := '';
	END IF;
	FromWhereArrayLen := ARRAY_UPPER(RootSelectorFromWhere, 1);
	FOR I IN 1 .. FromWhereArrayLen
	LOOP
		RootMultiSQL := RootMultiSQL || UnionPart
			|| '(SELECT Items.ItemURI, Items.ItemUserId, Items.ItemOriginURI ' || RootSelectorFieldsSQL || RootSelectorFromWhere[I][1] || ' ' || RootSelectorFromWhere[I][2] || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || RootSelectorLimit || ' OFFSET ' || RootSelectorOffset || ' )';
		UnionPart := ' UNION ALL ';
	END LOOP;
	RootMultiSQL := RootMultiSQL || ') Items ' || RootSelectorOrder;
	RETURN RootMultiSQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;



CREATE OR REPLACE FUNCTION ItemsGetRootsCountMulti(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, ItemUserId Items.ItemUserId%TYPE, ItemOriginURI Items.ItemOriginURI%TYPE) AS $$
DECLARE
	root_cursor REFCURSOR;
	root_sql VARCHAR;
	roots VARCHAR[][];
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
				roots := array_cat(roots, ARRAY[[ItemURI, ItemUserId, ItemOriginURI]]);
				cnt := cnt + 1;
				EXIT WHEN (cnt = RootSelectorLimit);
			END IF;
		END LOOP;
		CLOSE root_cursor;
		EXIT WHEN ((cnt = RootSelectorLimit) OR (cnt = old_cnt));
		cur_offset := cur_offset + double_limit;
	END LOOP;
	RETURN QUERY SELECT roots[i][1], roots[i][2], roots[i][3] FROM GENERATE_SERIES(1, ARRAY_UPPER(roots, 1)) i;
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

CREATE OR REPLACE FUNCTION ItemsGetCountMulti(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrderLimit VARCHAR,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemUserId Items.ItemUserId%TYPE) AS $$
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
		ChildrenSelectorGroupSQL = ChildrenSelectorGroup || ', R.Depth, R.Path, R.ItemUserId, R.ItemOriginURI';
	ELSE
		ChildrenSelectorGroupSQL = '';
	END IF;
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cycle) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], false, ItemUserId, ItemOriginURI'
		|| ' FROM ItemsGetRootsCountMulti('
		|| quote_literal(RootSelectorFields) || ','
		|| RootSelectorFromWhere || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemURI = ANY(R.Path), Items.ItemUserId, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI, Items.ItemUserId '
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
		|| ' SELECT ItemUserId FROM ITMS';
	RETURN QUERY EXECUTE SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetCountMulti(
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

