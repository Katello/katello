create or replace FUNCTION empty(t TEXT)
	RETURNS BOOLEAN as $$
	BEGIN
		return t ~ '^[[:space:]]*$';
	END;
$$ language 'plpgsql';

