# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

::User.current = ::User.anonymous_api_admin
os_attributes = {:major => "7", :minor => "2", :name => ::Operatingsystem::REDHAT_ATOMIC_HOST_OS}
Operatingsystem.where(os_attributes).first_or_create!

::User.current = nil
