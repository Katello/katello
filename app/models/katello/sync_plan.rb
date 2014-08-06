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

require 'time'

module Katello
class SyncPlan < Katello::Model
  self.include_root_in_json = false

  include Glue

  include Glue::ElasticSearch::SyncPlan if Katello.config.use_elasticsearch
  include Katello::Authorization::SyncPlan

  NONE = 'none'
  HOURLY = 'hourly'
  DAILY = 'daily'
  WEEKLY = 'weekly'
  TYPES = [NONE, HOURLY, DAILY, WEEKLY]
  DURATION = { NONE => '', HOURLY => 'T1H', DAILY => 'T24H', WEEKLY => '7D' }
  WEEK_DAYS = (%W(Sunday Monday Tuesday Wednesday Thursday Friday)).collect{|d| N_(d)}

  belongs_to :organization, :inverse_of => :sync_plans
  has_many :products, :class_name => "Katello::Product", :dependent => :nullify

  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
  validates :interval, :inclusion => {:in => TYPES}, :allow_blank => false
  validate :validate_sync_date
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_with OrganizationAssociationValidator

  before_save :reassign_sync_plan_to_products

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :organization_id, :complete_value => true

  def reassign_sync_plan_to_products
    # triggers orchestration in products
    self.products.each do |product|
      product.sync_plan = self # assign current updated sync_plan, don't let products to load sync_plan again
      product.save!
    end
  end

  def validate_sync_date
    errors.add :base, _("Start Date and Time can't be blank") if self.sync_date.nil?
  end

  def zone_converted
    #convert time to local timezone
    self.sync_date.localtime.to_datetime
  end

  def plan_day
    WEEK_DAYS[self.sync_date.strftime('%A').to_i]
  end

  def plan_date(localtime = true)
    date_obj = localtime ? self.zone_converted : self.sync_date
    date_obj.strftime('%m/%d/%Y')
  end

  def plan_time(localtime = true)
    date_obj = localtime ? self.zone_converted : self.sync_date
    date_obj.strftime('%I:%M %p')
  end

  def schedule_format
    if self.interval != NONE && DURATION[self.interval]
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

  def next_sync
    now = Time.zone.local_to_utc(Time.now)
    next_sync = self.sync_date

    if self.sync_date < now
      hours = self.sync_date.hour - now.hour
      minutes = self.sync_date.min - now.min
      seconds = self.sync_date.sec - now.sec

      case self.interval
      when HOURLY
        if self.sync_date.min < now.min
          minutes += 60
        end
        next_sync = now.advance(:minutes => minutes, :seconds => seconds)
      when DAILY
        sync_time = Time.at(self.sync_date.hour * 60 * 60 + self.sync_date.min * 60 + self.sync_date.sec)
        now_time = Time.at(now.hour * 60 * 60 + now.min * 60 + now.sec)
        if sync_time < now_time
          hours += 24
        end
        next_sync = now.advance(:hours => hours, :minutes => minutes, :seconds => seconds)
      when WEEKLY
        days = 7 + self.sync_date.wday - now.wday
        next_sync = now.change(:hour => self.sync_date.hour, :min => self.sync_date.min,
                               :sec => self.sync_date.sec).advance(:days => days)
      else
        next_sync = nil
      end
    end

    next_sync
  end

  private

  def self.humanize_class_name(name = nil)
    _("Sync Plans")
  end

end
end
