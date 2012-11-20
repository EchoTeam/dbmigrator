CREATE OR REPLACE FUNCTION GetUsersItems(
	ItemUserIds TEXT[],
	CountLimit INT,
	Period VARCHAR
) RETURNS TABLE (ItemURI Items.ItemURI%TYPE) AS $$
BEGIN
	RETURN QUERY (
		SELECT Items.ItemURI FROM Items
		WHERE Items.ItemUserId = ANY(ItemUserIds)
			AND Items.ItemCreationTimestamp >
				(CURRENT_TIMESTAMP - Period::INTERVAL)
		ORDER BY Items.ItemCreationTimestamp DESC
		LIMIT CountLimit
	);
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION GetUsersItems(
	TEXT[],
	INT,
	VARCHAR
) TO PUBLIC;
