CREATE TYPE AbstractItemsRootsType AS (
	ItemURI VARCHAR,
	ItemsSpecificField VARCHAR,
	ItemOriginURI VARCHAR
);

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

CREATE OR REPLACE FUNCTION ItemsGetRoots_v2(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsType AS $$
DECLARE
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM ' || InternalItemsGetRootsSQL(false, RootSelectorFrom, RootSelectorWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRoots_v2(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetRootsCount_v2(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsCountType AS $$
DECLARE
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM ' || InternalItemsGetRootsSQL(true, RootSelectorFrom, RootSelectorWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsCount_v2(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetRootsMulti_v2(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsType AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM ' || InternalItemsGetRootsMultiSQL(false, RootSelectorFields, RootSelectorFromWhere, RootSelectorOrder, RootSelectorLimit, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsMulti_v2(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetRootsCountMulti_v2(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS SETOF ItemsGetRootsCountType AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM ' || InternalItemsGetRootsMultiSQL(true, RootSelectorFields, RootSelectorFromWhere, RootSelectorOrder, RootSelectorLimit, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetRootsCountMulti_v2(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetCount_v2(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
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
	RootSQL VARCHAR;
BEGIN
	RootSQL := InternalItemsGetRootsSQL(true, RootSelectorFrom, RootSelectorWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
	RETURN QUERY EXECUTE AbstractItemsGetCountSQL(RootSQL,
		ChildrenSelectorFrom, ChildrenSelectorWhere,
		ChildrenSelectorGroup, ChildrenSelectorOrderLimit,
		Depth, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetCount_v2(
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

CREATE OR REPLACE FUNCTION ItemsGetCountMulti_v2(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
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
	RootSQL VARCHAR;
BEGIN
	RootSQL := InternalItemsGetRootsMultiSQL(true,
		RootSelectorFields, RootSelectorFromWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
	RETURN QUERY EXECUTE AbstractItemsGetCountSQL(RootSQL,
		ChildrenSelectorFrom, ChildrenSelectorWhere,
		ChildrenSelectorGroup, ChildrenSelectorOrderLimit,
		Depth, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetCountMulti_v2(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	INT,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGet_v2(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrder VARCHAR,
	ChildrenSelectorLimit INT,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, Cnvrs Items.ItemURI_Original%TYPE) AS $$
DECLARE
	RootSQL VARCHAR;
BEGIN
	RootSQL := InternalItemsGetRootsSQL(false, RootSelectorFrom, RootSelectorWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
	RETURN QUERY EXECUTE AbstractItemsGetSQL(RootSQL,
		ChildrenSelectorFrom, ChildrenSelectorWhere,
		ChildrenSelectorGroup, ChildrenSelectorOrder,
		ChildrenSelectorLimit, Depth, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGet_v2(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	INT,
	VARCHAR
) TO PUBLIC;

CREATE OR REPLACE FUNCTION ItemsGetMulti_v2(
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrder VARCHAR,
	ChildrenSelectorLimit INT,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS TABLE (ItemURI Items.ItemURI%TYPE, Cnvrs Items.ItemURI_Original%TYPE) AS $$
DECLARE
	RootSQL VARCHAR;
BEGIN
	RootSQL := InternalItemsGetRootsMultiSQL(false,
		RootSelectorFields, RootSelectorFromWhere,
		RootSelectorOrder, RootSelectorLimit, ExcKey);
	RETURN QUERY EXECUTE AbstractItemsGetSQL(RootSQL,
		ChildrenSelectorFrom, ChildrenSelectorWhere,
		ChildrenSelectorGroup, ChildrenSelectorOrder,
		ChildrenSelectorLimit, Depth, ExcKey);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGetMulti_v2(
	VARCHAR,
	VARCHAR[][],
	VARCHAR,
	INT,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	INT,
	VARCHAR
) TO PUBLIC;

--- PRIVATE FUNCTIONS ---

CREATE OR REPLACE FUNCTION AbstractItemsGetRoots(
	root_sql0 VARCHAR,
	RootSelectorLimit INT,
	movable_offset BOOLEAN
	) RETURNS SETOF AbstractItemsRootsType AS $$
DECLARE
	root_sql VARCHAR;
	root_cursor REFCURSOR;
	root AbstractItemsRootsType%ROWTYPE;
	roots_uris VARCHAR[] = ARRAY[]::VARCHAR[];
	ItemURI Items.ItemURI%TYPE;
	ItemsSpecificField VARCHAR;
	ItemOriginURI Items.ItemOriginURI%TYPE;
	double_limit INT;
	cnt INT = 0;
	old_cnt INT;
	cur_offset INT = 0;
BEGIN
	double_limit := RootSelectorLimit * 2;
	LOOP
		IF (movable_offset) THEN
			root_sql := root_sql0 || ' LIMIT ' || double_limit || ' OFFSET ' || cur_offset;
		ELSE
			root_sql := root_sql0;
		END IF;
		old_cnt := cnt;
		OPEN root_cursor FOR EXECUTE root_sql0;
		LOOP
			FETCH root_cursor INTO ItemURI, ItemsSpecificField, ItemOriginURI;
			EXIT WHEN NOT FOUND;
			IF ((NOT ItemURI = ANY(roots_uris)) OR array_length(roots_uris, 1) IS NULL) THEN
				roots_uris := roots_uris || ItemURI;
				root.ItemURI := ItemURI;
				root.ItemsSpecificField := ItemsSpecificField;
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

CREATE OR REPLACE FUNCTION AbstractItemsGetRootsCount(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
) RETURNS SETOF AbstractItemsRootsType AS
$$
DECLARE
	root_sql VARCHAR;
BEGIN
	root_sql := 'SELECT Items.ItemURI, '
			|| 'MIN(Items.ItemUserId)::VARCHAR AS ItemsSpecificField, '
			|| 'MIN(Items.ItemOriginURI)::VARCHAR AS ItemOriginURI '
			|| RootSelectorFrom || ' '
			|| RootSelectorWhere || ' '
			|| 'AND (Items.ItemExcKey = ''' || ExcKey || ''' '
			|| 'OR  (Items.ItemMasterVersion '
			|| 'AND NOT EXISTS (SELECT 1 FROM ItemExceptions '
				|| 'WHERE ItemExceptions.ItemURI=Items.ItemURI '
				|| 'AND ItemExceptions.ItemExcKey=''' || ExcKey || '''))) '
			|| 'GROUP BY Items.ItemURI LIMIT ' || RootSelectorLimit;

	RETURN QUERY EXECUTE root_sql;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION SpecificFieldName (
	IsCounter BOOLEAN
	) RETURNS VARCHAR AS $$
BEGIN
	IF (IsCounter) THEN RETURN 'ItemUserId';
	ELSE RETURN 'ItemURI_Original';
	END IF;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION InternalItemsGetRootsSQL(
	IsCounter BOOLEAN,
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	root_sql VARCHAR;
BEGIN
	IF IsCounter THEN
		RETURN 'AbstractItemsGetRootsCount('
			|| quote_literal(RootSelectorFrom) || ', '
			|| quote_literal(RootSelectorWhere) || ', '
			|| RootSelectorLimit || ', '
			|| quote_literal(ExcKey) || ')';
	ELSE
		root_sql := SelectRootsSQL(IsCounter, RootSelectorFrom, RootSelectorWhere, RootSelectorOrder, ExcKey);
		RETURN 'AbstractItemsGetRoots(' || quote_literal(root_sql) || ', ' || RootSelectorLimit || ', true)';
	END IF;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION InternalItemsGetRootsMultiSQL(
	IsCounter BOOLEAN,
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	root_sql VARCHAR;
BEGIN
	root_sql := SelectRootsMultiSQL(IsCounter, RootSelectorFields, RootSelectorFromWhere, RootSelectorOrder, RootSelectorLimit, ExcKey);
	RETURN 'AbstractItemsGetRoots(' || quote_literal(root_sql) || ', ' || RootSelectorLimit || ', false)';
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION AbstractItemsGetCountSQL(
	RootSQL VARCHAR,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrderLimit VARCHAR,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
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
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, ItemUserId, ItemOriginURI) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], ItemsSpecificField AS ItemUserId, ItemOriginURI FROM '
		|| RootSQL
		|| ' AS Roots '
		|| ' UNION ALL'
		|| ' SELECT * FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]), Items.ItemUserId, R.ItemOriginURI '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI, Items.ItemUserId '
		|| ChildrenSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || ChildrenSelectorWhereSQL
		|| '(Items.ItemExcKey = ''' || ExcKey 
		|| ''' OR (Items.ItemMasterVersion AND ItemExceptions.ItemExcKey IS NULL)) ' 
		|| ' ) AS Items '
		|| ' INNER JOIN ITMS R ON Items.ItemParentURI = R.ItemURI '
		|| ' AND Items.ItemOriginURI = R.ItemOriginURI '
		|| ' AND NOT (Items.ItemURI = ANY(R.Path)) ' || DepthSQL
		|| ' ' || ChildrenSelectorGroupSQL
		|| ' ' || ChildrenSelectorOrderLimit
		|| ' ) AS T)'
		|| ' SELECT ItemUserId FROM ITMS';
	RETURN SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION AbstractItemsGetSQL(
	RootSQL VARCHAR,
	ChildrenSelectorFrom VARCHAR,
	ChildrenSelectorWhere VARCHAR,
	ChildrenSelectorGroup VARCHAR,
	ChildrenSelectorOrder VARCHAR,
	ChildrenSelectorLimit INT,
	Depth INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
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
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cnvrs, ItemOriginURI) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], ItemsSpecificField as Cnvrs , ItemOriginURI FROM '
		|| RootSQL 
		|| ' AS Roots '
		|| ' UNION ALL'
		|| ' SELECT ItemURI, Depth, Path, Cnvrs, ItemOriginURI FROM '
		|| ' (SELECT Items.ItemURI, R.Depth + 1 as Depth, CAST(R.Path || Items.ItemURI AS VARCHAR(255)[]) as Path, R.Cnvrs, R.ItemOriginURI, rank() OVER (PARTITION BY Items.ItemParentURI, Items.ItemOriginURI ' || ChildrenSelectorOrder || ' ) as rank '
		|| ' FROM ( SELECT Items.ItemURI, Items.ItemParentURI, Items.ItemCreationTimestamp, Items.ItemOriginURI '
		|| ChildrenSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || ChildrenSelectorWhereSQL
		|| '(Items.ItemExcKey = ''' || ExcKey 
		|| ''' OR (Items.ItemMasterVersion AND ItemExceptions.ItemExcKey IS NULL)) ' 
		|| ' ) AS Items '
		|| ' INNER JOIN ITMS R ON Items.ItemParentURI = R.ItemURI '
		|| ' AND Items.ItemOriginURI = R.ItemOriginURI '
		|| ' AND NOT (Items.ItemURI = ANY(R.Path)) ' || DepthSQL
		|| ' ' || ChildrenSelectorGroupSQL
		|| ' ' || ChildrenSelectorOrder
		|| ' ) AS T WHERE rank <= ' || ChildrenSelectorLimit || ' ) '
		|| ' SELECT ItemURI, Cnvrs FROM ITMS';
	RETURN SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION SelectRootsSQL(
	IsCounter BOOLEAN,
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorOrder VARCHAR,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	SelectItems VARCHAR;
BEGIN
	RETURN 'SELECT Items.ItemURI, Items.' || SpecificFieldName(IsCounter) || ' AS ItemsSpecificField, Items.ItemOriginURI '
	|| RootSelectorFrom || ' ' || RootSelectorWhere || ' AND (Items.ItemExcKey = ''' || ExcKey
	|| ''' OR (Items.ItemMasterVersion AND  NOT EXISTS (SELECT 1 FROM ItemExceptions WHERE ItemExceptions.ItemURI=Items.ItemURI AND ItemExceptions.ItemExcKey='''
	|| ExcKey || '''))) ' || RootSelectorOrder;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION SelectRootsMultiSQL(
	IsCounter BOOLEAN,
	RootSelectorFields VARCHAR,
	RootSelectorFromWhere VARCHAR[][],
	RootSelectorOrder VARCHAR,
	RootSelectorLimit INT,
	ExcKey VARCHAR
	) RETURNS VARCHAR AS $$
DECLARE
	RootMultiSQL VARCHAR;
	RootSQL VARCHAR;
	RootSelectorFieldsSQL VARCHAR;
	FromWhereArrayLen INT;
	UnionPart VARCHAR := '';
	double_limit INT;
BEGIN
	IF (RootSelectorFields != '') THEN
		RootSelectorFieldsSQL := ', ' || RootSelectorFields || ' ';
	ELSE
		RootSelectorFieldsSQL := '';
	END IF;
	FromWhereArrayLen := ARRAY_UPPER(RootSelectorFromWhere, 1);
	RootMultiSQL := 'SELECT Items.ItemURI, Items.ItemsSpecificField, Items.ItemOriginURI FROM (';
	double_limit := RootSelectorLimit * 2;
	FOR I IN 1 .. FromWhereArrayLen
	LOOP
        RootSQL := SelectRootsSQL(IsCounter, RootSelectorFieldsSQL, RootSelectorFromWhere[I][1] || ' ' || RootSelectorFromWhere[I][2],
            RootSelectorOrder, ExcKey);
		RootMultiSQL := RootMultiSQL || UnionPart
            || '(' || RootSQL || ' LIMIT ' || double_limit || ' )';
		UnionPart := ' UNION ALL ';
	END LOOP;
	RootMultiSQL := RootMultiSQL || ') Items ' || RootSelectorOrder;
	RETURN RootMultiSQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;
