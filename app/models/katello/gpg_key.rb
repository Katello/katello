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
  class GpgKey < Katello::Model
    self.include_root_in_json = false

    include Katello::Authorization::GpgKey
    MAX_CONTENT_LENGTH = 100_000
    MAX_CONTENT_LINE_LENGTH = 65

    has_many :repositories, :class_name => "Katello::Repository", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :products, :class_name => "Katello::Product", :inverse_of => :gpg_key, :dependent => :nullify

    belongs_to :organization, :inverse_of => :gpg_keys

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("has already been taken")}
    validates :content, :presence => true, :length => {:maximum => MAX_CONTENT_LENGTH}
    validates :organization, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::ContentValidator, :attributes => :content
    validates_with Validators::GpgKeyContentValidator, :attributes => :content, :if => proc { Katello.config.gpg_strict_validation }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true

    def as_json(options = {})
      options ||= {}
      ret = super(options.except(:details))
      if options[:details]
        ret[:products] = products.map { |p| {:name => p.name} }
        ret[:repositories] = repositories.map { |r| {:product => {:name => r.product.name}, :name => r.name} }
      end
      ret
    end

    def self.humanize_class_name(_name = nil)
      _("GPG Keys")
    end
  end
end
