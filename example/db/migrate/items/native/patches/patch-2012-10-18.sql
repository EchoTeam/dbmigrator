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

