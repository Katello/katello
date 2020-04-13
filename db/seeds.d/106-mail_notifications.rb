# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#
User.as(::User.anonymous_api_admin.login) do
  # The notification names are used as humanized labels. These need to be
  # translated as well as the description
  N_('Host errata advisory')
  N_('Sync errata')
  N_('Promote errata')

  # Mail Notifications
  notifications = [
    {:name => :host_errata_advisory,
     :description => N_('A summary of available and applicable errata for your hosts'),
     :mailer => 'Katello::ErrataMailer',
     :method => 'host_errata',
     :subscription_type => 'report'
    },

    {:name => :sync_errata,
     :description => N_('A summary of new errata after a repository is synchronized'),
     :mailer => 'Katello::ErrataMailer',
     :method => 'sync_errata',
     :subscription_type => 'alert'
    },

    {:name => :promote_errata,
     :description => N_('A post-promotion summary of hosts with installable errata'),
     :mailer => 'Katello::ErrataMailer',
     :method => 'promote_errata',
     :subscription_type => 'alert'
    },

    {:name => :subscriptions_expiring_soon,
     :description => N_('A list of subscriptions expiring within 30 days'),
     :mailer => 'Katello::SubscriptionMailer',
     :method => 'subscription_expiry',
     :subscription_type => 'report',
     :queryable => true
    }
  ]

  notifications.each do |notification|
    ::MailNotification.where(name: notification[:name]).first_or_create!(notification)
  end
end
