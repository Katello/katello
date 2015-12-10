# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
::User.current = ::User.anonymous_api_admin

Setting.find_by(:name => "dynflow_enable_console").update_attributes!(:value => true) if Rails.env.development?
::User.current = nil
