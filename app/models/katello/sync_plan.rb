require 'time'

module Katello
  class SyncPlan < Katello::Model
    self.include_root_in_json = false

    include Glue
    include Katello::Authorization::SyncPlan
    include ForemanTasks::Concerns::ActionSubject

    HOURLY = 'hourly'
    DAILY = 'daily'
    WEEKLY = 'weekly'
    TYPES = [HOURLY, DAILY, WEEKLY]
    DURATION = {HOURLY => 'T1H', DAILY => 'T24H', WEEKLY => '7D' }
    WEEK_DAYS = (%w(Sunday Monday Tuesday Wednesday Thursday Friday)).collect { |d| N_(d) }

    belongs_to :organization, :inverse_of => :sync_plans
    has_many :products, :class_name => "Katello::Product", :dependent => :nullify

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
    validates :interval, :inclusion => {:in => TYPES}, :allow_blank => false
    validates :enabled, :inclusion => [true, false]
    validate :validate_sync_date
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true
    scoped_search :on => :interval, :complete_value => true
    scoped_search :on => :enabled, :complete_value => true

    def validate_sync_date
      errors.add :base, _("Start Date and Time can't be blank") if self.sync_date.nil?
    end

    def plan_day
      WEEK_DAYS[self.sync_date.strftime('%A').to_i]
    end

    def plan_date
      self.sync_date.strftime('%m/%d/%Y')
    end

    def plan_time
      self.sync_date.strftime('%I:%M %p')
    end

    def plan_date_time
      self.sync_date.strftime('%Y/%m/%d %H:%M:%S %Z')
    end

    def schedule_format
      if (self.interval != DURATION[self.interval])
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
      return nil unless self.enabled
      now = Time.current
      next_sync = self.sync_date

      if self.sync_date < now
        hours = self.sync_date.hour - now.hour
        minutes = self.sync_date.min - now.min
        seconds = self.sync_date.sec - now.sec

        next_sync = nil

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
        end
      end

      next_sync = next_sync.strftime('%Y/%m/%d %H:%M:%S %Z') if next_sync
      next_sync
    end

    def self.humanize_class_name(_name = nil)
      _("Sync Plans")
    end
  end
end
