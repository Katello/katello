CREATE TRIGGER evr_insert_trigger_katello_rpms
  BEFORE INSERT
  ON katello_rpms
  FOR EACH ROW
  EXECUTE PROCEDURE evr_trigger();
