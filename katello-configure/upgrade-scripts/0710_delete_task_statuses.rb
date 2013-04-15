#!/usr/bin/ruby
#name: Delete old task status objects
#apply: katello headpin
#run: once
#description:
# https://github.com/Katello/katello/issues/1963 
# In the past Tire Index objects were stored as
#  the result of a delayed job.  In rails 3.2 these
#  objects cannot be serialized or deserialized
#  so loading these objects fail.

ENV["RAILS_ENV"] = 'production'
require "/usr/share/katello/config/boot"
require "/usr/share/katello/config/application"
Rails.application.require_environment!


TaskStatus.delete_all
