CREATE TRIGGER evr_update_trigger_katello_installed_packages
  BEFORE UPDATE OF epoch, version, release
  ON katello_installed_packages
  FOR EACH ROW
  WHEN (
    OLD.epoch IS DISTINCT FROM NEW.epoch OR
    OLD.version IS DISTINCT FROM NEW.version OR
    OLD.release IS DISTINCT FROM NEW.release
  )
  EXECUTE PROCEDURE evr_trigger();
