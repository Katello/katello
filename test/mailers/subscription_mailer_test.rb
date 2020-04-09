require 'katello_test_helper'

module Katello
  class SubscriptionMailertest < ActiveSupport::TestCase
    def setup
      @user = User.current = User.find(users('admin').id)

      FactoryBot.create(:mail_notification,
                        :name => 'subscriptions_expiring_soon',
                        :description => 'A list of subscriptions expiring within 30 days',
                        :mailer => 'Katello::SubscriptionMailer',
                        :method => 'subscription_expiry',
                        :subscription_type => 'report')

      @user.mail_notifications << MailNotification[:subscriptions_expiring_soon]

      @pool_not_expiring_soon = FactoryBot.create(:katello_pool,
                                                  :not_expiring_soon,
                                                  cp_id: "1234",
                                                  subscription_id: ActiveRecord::FixtureSet.identify(:other_subscription))
      ActionMailer::Base.deliveries = []
    end

    def setup_expiring_pool
      @pool_expiring_soon = FactoryBot.create(:katello_pool,
                                              :expiring_in_12_days,
                                              cp_id: "123",
                                              subscription_id: ActiveRecord::FixtureSet.identify(:basic_subscription),
                                              organization_id: ActiveRecord::FixtureSet.identify(:empty_organization),
                                              pool_type: "normal",
                                              quantity: 10,
                                              start_date: "2011-10-11T04:00:00.000+0000",
                                              account_number: "12400203",
                                              contract_number: "123403949")
    end

    def test_prevent_sending_blank_report
      @user.user_mail_notifications.first.deliver

      assert_empty ActionMailer::Base.deliveries
    end

    def get_rows(email)
      doc = Nokogiri::HTML(email, nil, 'UTF-8')
      table = doc.css('table').first
      table.css('tr')
    end

    def test_includes_expiring_subscription
      setup_expiring_pool
      @user.user_mail_notifications.first.deliver
      email = ActionMailer::Base.deliveries.first

      rows = get_rows(email.body.encoded)
      subscription_row = rows[1]
      subscription_cells = subscription_row.css('td')

      fields = [ @pool_expiring_soon.subscription.name,
                 @pool_expiring_soon.account_number.to_s,
                 @pool_expiring_soon.organization.name,
                 @pool_expiring_soon.pool_type,
                 @pool_expiring_soon.quantity.to_s,
                 @pool_expiring_soon.subscription.cp_id,
                 @pool_expiring_soon.contract_number.to_s,
                 @pool_expiring_soon.start_date.to_s,
                 @pool_expiring_soon.end_date.to_s,
                 @pool_expiring_soon.days_until_expiration.to_s]

      fields.each_with_index do |field, i|
        assert_equal field, subscription_cells[i].children.text
      end
    end

    def test_omits_non_expiring_subscription
      setup_expiring_pool
      @user.user_mail_notifications.first.deliver
      email = ActionMailer::Base.deliveries.first
      rows = get_rows(email.body.encoded)

      # row headings is counted as one row
      assert_equal rows.length, 2
      assert Katello::Pool.readable.size > 1
    end
  end
end
