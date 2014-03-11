#
# Copyright 2014 Red Hat, Inc.
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
  class ContentViewPuppetModule < Katello::Model
    self.include_root_in_json = false

    include Glue::ElasticSearch::ContentViewPuppetModule if Katello.config.use_elasticsearch

    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions

    validates :content_view_id, :presence => true
    validates :name, :uniqueness => { :scope => :content_view_id }, :allow_blank => true
    validates :uuid, :uniqueness => { :scope => :content_view_id }, :allow_blank => true

    validates_with Validators::ContentViewPuppetModuleValidator

    before_save :set_attributes

    private

    def set_attributes
      if self.uuid && Katello.config.use_pulp
        puppet_module = PuppetModule.find(self.uuid)
        fail Errors::NotFound, _("Couldn't find Puppet Module with id=%s") % self.uuid unless puppet_module

        self.name = puppet_module.name
        self.author = puppet_module.author
      end
    end
  end
end
