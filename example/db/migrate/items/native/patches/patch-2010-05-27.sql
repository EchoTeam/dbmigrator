CREATE OR REPLACE FUNCTION ItemsGet(
	RootSelectorFrom VARCHAR,
	RootSelectorWhere VARCHAR,
	RootSelectorGroup VARCHAR,
	RootSelectorOrderLimit VARCHAR,
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
	SET ENABLE_HASHJOIN = OFF;
	SET ENABLE_MERGEJOIN = OFF;
	SET ENABLE_SEQSCAN = OFF;
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
		|| ' FROM ( SELECT Items.ItemURI,Items.ItemURI_Original,Items.ItemOriginURI ' 
		|| RootSelectorFrom || ' LEFT JOIN ItemExceptions ' 
		|| 'ON Items.ItemURI = ItemExceptions.ItemURI AND ItemExceptions.ItemExcKey=''' 
		|| ExcKey || ''' ' || RootSelectorWhere 
		|| ' AND (Items.ItemExcKey = ''' || ExcKey 
		|| ''' OR (Items.ItemMasterVersion AND ItemExceptions.ItemExcKey IS NULL)) ' 
		|| RootSelectorGroup || ' ' || RootSelectorOrderLimit 
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
	SET ENABLE_HASHJOIN = ON;
	SET ENABLE_MERGEJOIN = ON;
	SET ENABLE_SEQSCAN = ON;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION ItemsGet(
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	VARCHAR,
	INT,
	VARCHAR
) TO PUBLIC;

