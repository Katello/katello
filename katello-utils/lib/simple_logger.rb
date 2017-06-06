#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# Manifest representation in Ruby
#

# Simple logging class used by katello-disconnected and other command-line
# utilities. It has similar API as Rails logger anc can be used as Rails
# logger using the following trick:
#
#     module Rails; def self.logger; L; end; end
#
class SimpleLogger
  attr_accessor :logger
  delegate :level, :level=, :debug, :debug?, :error, :error?, :info, :info?, :warn, :warn?, :to => :logger
  # INFO = VERBOSE
  alias_method :verbose, :info
  alias_method :verbose?, :info?

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
  end

  def fatal msg
    logger.fatal msg
    exit 1
  end
  alias_method :f, :fatal
end
