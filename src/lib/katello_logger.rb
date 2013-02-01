#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class KatelloLogger < ActiveSupport::BufferedLogger
  def initialize(log, level)
    level = {
      "DEBUG" => 0,
      "INFO" => 1,
      "WARN" => 2,
      "WARNING" => 2,
      "ERROR" => 3,
      "FATAL" => 4
    }[level.upcase] if level.is_a? String

    super(log, level)

    # this is not needed for Rails 3.2+ and will warn about deprecated call
    @auto_flushing = 1 if instance_variable_defined?(:@auto_flushing)
  end

  SEVERITY_TO_TEXT = ['DEBUG',' INFO',' WARN','ERROR','FATAL']

  def add(severity, message = nil, progname = nil, &block)
    status = SEVERITY_TO_TEXT[severity] || "UNKNOWN"
    unless level > severity
      message = (message || (block && block.call) || progname).to_s
      status = SEVERITY_TO_TEXT[severity] || "UNKNOWN"
      message = "[%s %s %s #%d] %s" % [status,
                                     Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                                     Thread.current[:request_uuid],
                                     $$,
                                     message]
      super(severity, message)
    end
  end
end
