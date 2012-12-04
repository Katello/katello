#!/usr/bin/ruby

#name: Create first Foreman user
#apply: katello
#run: once
#description:
#This steps is executed only once and creates and associates the first Foreman
#admin user with Katello.

require "/usr/share/katello/config/environment.rb"

User.current = User.hidden.first
User.find_each do |katello_user|
  unless katello_user.foreman_user
    if (foreman_user = ::Foreman::User.all(:search => "login=#{katello_user.username}").first)
      katello_user.send :foreman_user=, foreman_user
      katello_user.save!
    else
      katello_user.create_foreman_user
    end
  end
end
