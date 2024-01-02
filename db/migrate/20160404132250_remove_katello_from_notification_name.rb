class RemoveKatelloFromNotificationName < ActiveRecord::Migration[4.2]
  def up
    # historical placeholder
    # only required on setups before https://projects.theforeman.org/issues/14459
    # we can safely assume that fresh installs have the above change already
    # and existing install had this migration applied back in 2016
  end
end
