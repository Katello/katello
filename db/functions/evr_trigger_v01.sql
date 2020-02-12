CREATE FUNCTION evr_trigger() RETURNS trigger AS $$
  BEGIN
    NEW.evr = (select ROW(coalesce(NEW.epoch::numeric,0),
                          rpmver_array(coalesce(NEW.version,'empty'))::evr_array_item[],
                          rpmver_array(coalesce(NEW.release,'empty'))::evr_array_item[])::evr_t);
    RETURN NEW;
  END;
$$ language 'plpgsql';

