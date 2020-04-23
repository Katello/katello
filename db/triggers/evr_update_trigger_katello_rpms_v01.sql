CREATE TRIGGER evr_update_trigger_katello_rpms
  BEFORE UPDATE OF epoch, version, release
  ON katello_rpms
  FOR EACH ROW
  WHEN (
    OLD.epoch IS DISTINCT FROM NEW.epoch OR
    OLD.version IS DISTINCT FROM NEW.version OR
    OLD.release IS DISTINCT FROM NEW.release
  )
  EXECUTE PROCEDURE evr_trigger();
