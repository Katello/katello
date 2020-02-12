CREATE TRIGGER evr_insert_trigger_katello_installed_packages
  BEFORE INSERT
  ON katello_installed_packages
  FOR EACH ROW
  EXECUTE PROCEDURE evr_trigger();
