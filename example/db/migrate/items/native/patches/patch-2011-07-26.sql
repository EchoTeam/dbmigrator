CREATE OR REPLACE FUNCTION ItemsGet(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
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
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], ItemURI_Original as Cnvrs , ItemOriginURI'
		|| ' FROM ItemsGetRoots('
		|| quote_literal(RootSelectorFrom) || ','
		|| quote_literal(RootSelectorWhere) || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
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
	RETURN QUERY EXECUTE SQL;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGet(
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
	ChildrenSelectorOrder VARCHAR,
	ChildrenSelectorLimit INT,
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
	SQL := ' WITH RECURSIVE ITMS(ItemURI, Depth, Path, Cnvrs, ItemOriginURI) AS ( '
		|| ' SELECT ItemURI, 0, ARRAY[ItemURI], ItemURI_Original as Cnvrs , ItemOriginURI'
		|| ' FROM ItemsGetRootsMulti('
		|| quote_literal(RootSelectorFields) || ','
		|| RootSelectorFromWhere || ','
		|| quote_literal(RootSelectorGroup) || ','
		|| quote_literal(RootSelectorOrder) || ','
		|| RootSelectorLimit || ','
		|| quote_literal(ExcKey)
		|| ' ) AS Roots '
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

