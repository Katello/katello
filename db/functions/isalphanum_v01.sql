create or replace FUNCTION isalphanum(ch CHAR)
	RETURNS BOOLEAN as $$
	BEGIN
		if ascii(ch) between ascii('a') and ascii('z') or
			ascii(ch) between ascii('A') and ascii('Z') or
			ascii(ch) between ascii('0') and ascii('9')
		then
			return TRUE;
		end if;
		return FALSE;
	END;
$$ language 'plpgsql';
