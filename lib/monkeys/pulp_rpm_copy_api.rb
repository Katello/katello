require 'pulp_rpm_client'

module PulpRpmClient
  class RpmCopyApi
    if instance_methods.include?(:copy_contents)
      Rails.logger.warning("Pulp_rpm_copy_api Monkey patch no longer needed, remove me!")
    else
      alias_method :copy_content, :create
    end
  end
end
