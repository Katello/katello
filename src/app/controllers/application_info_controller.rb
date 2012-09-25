class ApplicationInfoController < ApplicationController
  skip_before_filter :authorize

  def section_id
    # use the dashboard layout
    "dashboard"
  end

  def about
    @ping = Ping.ping
    @packages = Ping.packages
    @system_info = {  "Application" => AppConfig.app_name,
                      "Version"     => AppConfig.katello_version
                   }
    if current_user.allowed_to? :read, :organizations
      @system_info.merge!("Environment" => Rails.env,
                          "OS"          => `uname -a`,
                          "Directory"   => Rails.root,
                          "Ruby" => RUBY_VERSION
                         )
    end
  end
end
