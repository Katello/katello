# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
User.as(::User.anonymous_api_admin.login) do
  Setting.find_by(:name => "dynflow_enable_console").update!(:value => true) if Rails.env.development?
end
