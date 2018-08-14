require 'time'

module Katello
  class SyncPlan < Katello::Model
    audited :associations => [:products]
    include Glue
    include Katello::Authorization::SyncPlan
    include ForemanTasks::Concerns::ActionSubject

    HOURLY = 'hourly'.freeze
    DAILY = 'daily'.freeze
    WEEKLY = 'weekly'.freeze
    TYPES = [HOURLY, DAILY, WEEKLY].freeze
    DURATION = {HOURLY => 'T1H', DAILY => 'T24H', WEEKLY => '7D' }.freeze
    WEEK_DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday).collect { |d| N_(d) }

    belongs_to :organization, :inverse_of => :sync_plans
    has_many :products, :class_name => "Katello::Product", :dependent => :nullify
    belongs_to :foreman_tasks_recurring_logic, :inverse_of => :sync_plan, :class_name => "ForemanTasks::RecurringLogic", :dependent => :destroy

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
    validates :interval, :inclusion => {:in => TYPES}, :allow_blank => false
    validates :enabled, :inclusion => [true, false]
    validate :validate_sync_date
    validate :product_enabled
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name

    before_destroy :cancel_recurring_logic

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :interval, :complete_value => true
    scoped_search :on => :enabled, :complete_value => true

    def product_enabled
      products.each do |product|
        errors.add :base, _("Can not add product %s because it is disabled.") % product.name unless product.enabled?
      end
    end

    def save_with_logic!
      associate_recurring_logic
      self.save!
      start_recurring_logic
    end

    def update_attributes_with_logics!(params)
      self.update_attributes!(params)
      if rec_logic_changed?
        old_rec_logic = self.foreman_tasks_recurring_logic
        associate_recurring_logic
        self.save!
        old_rec_logic.cancel
        start_recurring_logic
      end
      toggle_enabled if enabled_toggle?
    end

    def associate_recurring_logic
      self.foreman_tasks_recurring_logic = add_recurring_logic_to_sync_plan(self.sync_date, self.interval)
    end

    def toggle_enabled
      self.foreman_tasks_recurring_logic.enabled = self.enabled
    end

    def start_recurring_logic
      User.as_anonymous_admin do
        self.foreman_tasks_recurring_logic.start_after(::Actions::Katello::SyncPlan::Run, self.sync_date, self)
      end
    end

    def cancel_recurring_logic
      self.foreman_tasks_recurring_logic.cancel
    end

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
      self.sync_date.strftime('%Y/%m/%d %H:%M:%S %z')
    end

    def plan_zone
      self.sync_date.strftime('%Z')
    end

    def sync_time
      self.sync_date.utc.strftime('%H%M%S%N')
    end

    def next_sync_date
      return nil unless self.enabled
      now = Time.current
      next_sync = self.sync_date

      if self.sync_date < now
        hours = self.sync_date.hour - now.hour
        minutes = self.sync_date.min - now.min
        seconds = self.sync_date.sec - now.sec

        next_sync = nil
        now_time = now.utc.strftime('%H%M%S%N')

        case self.interval
        when HOURLY
          if self.sync_date.min < now.min
            minutes += 60
          end
          next_sync = now.advance(:minutes => minutes, :seconds => seconds)
        when DAILY
          if self.sync_time < now_time
            hours += 24
          end
          next_sync = now.advance(:hours => hours, :minutes => minutes, :seconds => seconds)
        when WEEKLY
          days = self.sync_date.wday - now.wday
          days += 7 if days < 0 || (days == 0 && self.sync_time <= now_time)
          next_sync = now.change(:hour => self.sync_date.hour, :min => self.sync_date.min,
                                 :sec => self.sync_date.sec).advance(:days => days)
        end
      end

      next_sync
    end

    def next_sync
      next_sync_date.try(:strftime, '%Y/%m/%d %H:%M:%S %z')
    end

    def self.humanize_class_name(_name = nil)
      _("Sync Plans")
    end

    def add_recurring_logic_to_sync_plan(sync_date, interval)
      sync_date_local_zone = sync_date
      min, hour, day = sync_date_local_zone.min, sync_date_local_zone.hour, sync_date_local_zone.wday
      if interval.nil?
        fail _("Interval cannot be nil")
      end
      if (interval.downcase.eql? "hourly")
        cron = min.to_s + " * * * *"
      elsif (interval.downcase.eql? "daily")
        cron = min.to_s + " " + hour.to_s + " * * *"
      elsif (interval.downcase.eql? "weekly")
        cron = min.to_s + " " + hour.to_s + " * * " + day.to_s
      else
        fail _("Interval not set correctly")
      end

      recurring_logic = ForemanTasks::RecurringLogic.new_from_cronline(cron)
      recurring_logic.save!
      fail _("Error saving recurring logic") if recurring_logic.nil?
      return recurring_logic
    end

    def rec_logic_changed?
      saved_change_to_attribute?(:sync_date) || saved_change_to_attribute?(:interval)
    end

    def enabled_toggle?
      saved_change_to_attribute?(:enabled)
    end
  end
end
