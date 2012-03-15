#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class SyncPlan < ActiveRecord::Base
  include Glue
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :sync_date, :description, :interval]

  mapping do
    indexes :name, :type => 'string', :analyzer => :keyword
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :sync_date, :type=>'date'
  end


  NONE = _('none')
  HOURLY = _('hourly')
  DAILY = _('daily')
  WEEKLY = _('weekly')
  TYPES = [NONE, HOURLY, DAILY, WEEKLY]
  DURATION = { NONE => '', HOURLY => 'T1H', DAILY => 'T24H', WEEKLY => '7D' }
  WEEK_DAYS = (%W(Sunday Monday Tuesday Wednesday Thursday Friday)).collect{|d| N_(d)}


  belongs_to :organization
  has_many :products

  validates :name, :presence => true, :katello_name_format => true
  validates_uniqueness_of :name, :scope => :organization_id
  validate :validate_sync_date
  validates_inclusion_of :interval,
    :in => TYPES,
    :allow_blank => false

  scope :readable, lambda { |org| ::Provider.any_readable?(org)? where(:organization_id => org.id ) : where("0 = 1") }

  before_save :reassign_sync_plan_to_products

  def reassign_sync_plan_to_products
    self.products.each &:save # triggers orchestration in products
  end

  def validate_sync_date
    errors.add :base, _("Start Date and Time can't be blank") if self.sync_date.nil?
  end

  def zone_converted 
     #convert time to local timezone
     self.sync_date.localtime.to_datetime
  end

  def plan_day
    WEEK_DAYS[self.sync_date.strftime('%e').to_i]
  end

  def plan_date localtime=true
    date_obj = localtime ? self.zone_converted : self.sync_date
    date_obj.strftime('%m/%d/%Y')
  end

  def plan_time localtime=true
    date_obj = localtime ? self.zone_converted : self.sync_date
    date_obj.strftime('%I:%M %p')
  end

  def schedule_format
    if self.interval != NONE
      format = self.sync_date.iso8601 << "/P" << DURATION[self.interval]
    else
      if self.sync_date < Time.now
        format = nil # do not schedule tasks in past
      else
        format = "R1/" << self.sync_date.iso8601 << "/P1D"
      end
    end
    return format
  end

  def plan_zone
    self.sync_date.strftime('%Z')
  end

  def extended_index_attrs
    {:name_sort=>name.downcase}
  end

end
