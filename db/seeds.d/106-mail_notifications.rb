# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
::User.current = ::User.anonymous_api_admin

# Mail Notifications
notifications = [
  {:name              => :katello_host_advisory,
   :description       => N_('A summary of available and applicable errata for your hosts'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'host_errata',
   :subscription_type => 'report'
  },

  {:name              => :katello_sync_errata,
   :description       => N_('A summary of new errata after a repository is synchronized'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'sync_errata',
   :subscription_type => 'alert'
  },

  {:name              => :katello_promote_errata,
   :description       => N_('A post-promotion summary of hosts with installable errata'),
   :mailer            => 'Katello::ErrataMailer',
   :method            => 'promote_errata',
   :subscription_type => 'alert'
  }
]

notifications.each do |notification|
  ::MailNotification.where(name: notification[:name]).first_or_create!(notification)
end

::User.current = nil
