#
# Copyright © 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

module Katello
  module ModelUtils

    @@table_to_model_hash = nil

    # hash in the form of "table_name" => ModelClass
    def self.table_to_model_hash
      return @@table_to_model_hash if @@table_to_model_hash

      # explicitly load all available model classes
      Dir.foreach("#{Rails.root}/app/models") { |f| require f if f =~ /.*\.[rR][bB]/ }

      # create the hash
      table_to_model_hash = Hash[ActiveRecord::Base.send(:descendants).collect{|c| [c.table_name, c]}]

      # in production mode we cache this
      @@table_to_model_hash = table_to_model_hash if Rails.env.production?

      # return generated hash
      table_to_model_hash
    end
  end
end
