# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
::User.current = ::User.anonymous_api_admin

if SETTINGS[:katello][:use_pulp]
  Katello::Repository.ensure_sync_notification
end
::User.current = nil
