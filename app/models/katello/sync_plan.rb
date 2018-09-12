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
    CUSTOM_CRON = 'custom cron'.freeze
    TYPES = [HOURLY, DAILY, WEEKLY, CUSTOM_CRON].freeze
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
    validate :custom_cron_interval_expression
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

    def custom_cron_interval_expression
      errors.add :base, _("Custom cron expression only needs to be set for interval value of custom cron") if cron_status_mismatch?
    end

    def save_with_logic!
      associate_recurring_logic
      self.save!
      start_recurring_logic
    end

    def update_attributes_with_logics!(params)
      transaction do
        params["cron_expression"] = '' unless params["interval"].eql? CUSTOM_CRON
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
    end

    def associate_recurring_logic
      self.foreman_tasks_recurring_logic = add_recurring_logic_to_sync_plan(self.sync_date, self.interval, self.cron_expression)
    end

    def toggle_enabled
      self.foreman_tasks_recurring_logic.enabled = self.enabled
    end

    def start_recurring_logic
      User.as_anonymous_admin do
        if self.sync_date.to_time < Time.now
          self.foreman_tasks_recurring_logic.start(::Actions::Katello::SyncPlan::Run, self)
        else
          self.foreman_tasks_recurring_logic.start_after(::Actions::Katello::SyncPlan::Run, self.sync_date, self)
        end
      end
    end

    def cancel_recurring_logic
      self.foreman_tasks_recurring_logic.cancel if self.foreman_tasks_recurring_logic
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
      return nil unless (self.enabled || !self.foreman_tasks_recurring_logic.tasks.nil?)
      self.foreman_tasks_recurring_logic.tasks.order(:start_at).last.start_at
    end

    def next_sync
      next_sync_date.try(:strftime, '%Y/%m/%d %H:%M:%S %z')
    end

    def self.humanize_class_name(_name = nil)
      _("Sync Plans")
    end

    def add_recurring_logic_to_sync_plan(sync_date, interval, cron_expression)
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
      elsif (interval.downcase.eql? CUSTOM_CRON)
        cron = cron_expression
      else
        fail _("Interval not set correctly")
      end

      recurring_logic = ForemanTasks::RecurringLogic.new_from_cronline(cron)
      unless recurring_logic.valid_cronline?
        fail _("Cron expression is not valid!")
      end
      recurring_logic.save!
      return recurring_logic
    end

    def rec_logic_changed?
      saved_change_to_attribute?(:sync_date) || saved_change_to_attribute?(:interval) || saved_change_to_attribute?(:cron_expression)
    end

    def enabled_toggle?
      saved_change_to_attribute?(:enabled)
    end

    def cron_status_mismatch?
      self.interval != CUSTOM_CRON && !(self.cron_expression.nil? || self.cron_expression.eql?(''))
    end
  end
end
