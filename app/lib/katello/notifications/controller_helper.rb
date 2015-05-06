module Katello
  module Notifications::ControllerHelper
    # defines helper to access notifications from controller
    # @example how to send notification from controller
    #   notify.success _("Welcome Back") + ", " + current_user.login, :persist => false
    #   notify.message _("'%s' no longer matches the current search criteria.") % @gpg_key["name"], :asynchronous => false
    #   notify.invalid_record @an_user
    #   notify.warning _("You must be logged in to access that page.")
    #   notify.error _("Please select at least one system group.")
    #   notify.exception an_exception
    # @see Notifier
    def notify
      @notifier ||= Notifications::Notifier.new(self, default_notify_options)
    end

    private

    # define default options for Notifier instance
    # @example to set current organization as notice's organization
    #     def default_notify_options
    #       { :organization => current_organization }
    #     end
    # @example not to set any organization for a notice
    #     def default_notify_options
    #       { :organization => nil }
    #     end
    def default_notify_options
      fail NotImplementedError
    end
  end
end
