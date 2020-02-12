create or replace FUNCTION isalpha(ch CHAR)
  RETURNS BOOLEAN as $$
  BEGIN
    if ascii(ch) between ascii('a') and ascii('z') or
        ascii(ch) between ascii('A') and ascii('Z')
    then
      return TRUE;
    end if;
    return FALSE;
  END;
$$ language 'plpgsql';
