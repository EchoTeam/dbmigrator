CREATE OR REPLACE FUNCTION ItemsGetRootsMultiSQL(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorGroup VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	RootSelectorOffset INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	RootMultiSQL VARCHAR := 'SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemOriginURI FROM (';
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
			|| '(SELECT Items.ItemURI, Items.ItemURI_Original, Items.ItemOriginURI ' || RootSelectorFieldsSQL || RootSelectorFromWhere[I][1] || ' ' || RootSelectorFromWhere[I][2] || ' AND (Items.ItemExcKey = ''' || ExcKey || ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) ' || RootSelectorOrder || ' LIMIT ' || RootSelectorLimit || ' OFFSET ' || RootSelectorOffset || ' )';
		UnionPart := ' UNION ALL ';
	END LOOP;
	RootMultiSQL := RootMultiSQL || ') Items ' || RootSelectorOrder;
	RETURN RootMultiSQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;



CREATE OR REPLACE FUNCTION ItemsGetRootsMulti(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
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
				roots := array_cat(roots, ARRAY[[ItemURI, ItemURI_Original, ItemOriginURI]]);
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

GRANT EXECUTE ON FUNCTION ItemsGetRootsMulti(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetMulti(
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
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, Cnvrs Items.ItemURI_Original%TYPE) AS $$
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
		ChildrenSelectorGroupSQL = ChildrenSelectorGroup || ', R.Depth, R.Path, R.Cnvrs, R.ItemOriginURI';
	ELSE
		ChildrenSelectorGroupSQL = '';
	END IF;
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cycle) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], false, ItemURI_Original as Cnvrs , ItemOriginURI'
		|| ' FROM ItemsGetRootsMulti('
		|| quote_literal(RootSelectorFields) || ','
		|| RootSelectorFromWhere || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemURI = ANY(R.Path), R.Cnvrs, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI '
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
		|| ' SELECT ItemURI, Cnvrs FROM ITMS';
	RETURN QUERY EXECUTE SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetMulti(
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

