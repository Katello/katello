class Setting::Katello < Setting
  def self.load_defaults
    return unless super

    self.transaction do
      [
        self.set('katello_default_provision', N_("Default provisioning template for new Operating Systems"), 'Katello Kickstart Default'),
        self.set('katello_default_finish', N_("Default finish template for new Operating Systems"), 'Katello Kickstart Default Finish'),
        self.set('katello_default_user_data', N_("Default user data for new Operating Systems"), 'Katello Kickstart Default User Data'),
        self.set('katello_default_PXELinux', N_("Default PXElinux template for new Operating Systems"), 'Kickstart default PXELinux'),
        self.set('katello_default_iPXE', N_("Default iPXE template for new Operating Systems"), 'Kickstart default iPXE'),
        self.set('katello_default_ptable', N_("Default partitioning table for new Operating Systems"), 'Kickstart default'),
        self.set('content_action_accept_timeout', N_("Time in seconds to wait for a Host to pickup a remote action"), 20),
        self.set('content_action_finish_timeout', N_("Time in seconds to wait for a Host to finish a remote action"), 3600)
      ].each { |s| self.create! s.update(:category => "Setting::Katello") }
    end
    true
  end
end
