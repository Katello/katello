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


module Katello
  class Candlepin::Content
    attr_accessor :name, :id, :type, :label, :vendor, :contentUrl, :gpgUrl

    def initialize(params = {})
      load_attributes(params)
    end

    def self.find(id)
      found = ::Resources::Candlepin::Content.get(id)
      ::Candlepin::Content.new(found)
    end

    def create
      created = Resources::Candlepin::Content.create self
      load_attributes(created)

      self
    end

    def destroy
      Resources::Candlepin::Content.destroy(@id)
    end

    def update(params = {})
      return self if params.empty?

      updated = Resources::Candlepin::Content.update(params.merge(:id => @id))
      load_attributes(updated)

      self
    end

    def load_attributes(params)
      params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end
  end
end
