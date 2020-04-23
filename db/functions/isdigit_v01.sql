create or replace function isdigit(ch CHAR)
	RETURNS BOOLEAN as $$
	BEGIN
	  if ascii(ch) between ascii('0') and ascii('9')
	  then
		return TRUE;
	  end if;
	  return FALSE;
	END ;
$$ language 'plpgsql';
