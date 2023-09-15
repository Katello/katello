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

    belongs_to :organization, :inverse_of => :sync_plans
    has_many :products, :class_name => "Katello::Product", :dependent => :nullify
    belongs_to :foreman_tasks_recurring_logic, :inverse_of => :sync_plan, :class_name => "ForemanTasks::RecurringLogic", :dependent => :destroy
    belongs_to :task_group, :class_name => 'Katello::SyncPlanTaskGroup', :inverse_of => :sync_plan

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
    validates :interval, :inclusion => {:in => TYPES}, :allow_blank => false
    validate :validate_sync_date
    validate :product_enabled
    validate :custom_cron_interval_expression
    validates_associated :products
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name

    before_destroy :cancel_recurring_logic

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :interval, :complete_value => true
    scoped_search :on => :enabled, :complete_value => { :true => true, :false => false }, :ext_method => :search_enabled

    def self.search_enabled(_key, operator, value)
      value = ::Foreman::Cast.to_bool(value)
      value = !value if operator == '<>'
      active_logics = ForemanTasks::RecurringLogic.where(:state => "active")
      active_logic_ids = active_logics.pluck(:id)
      if active_logic_ids.empty?
        {:conditions => "1=0"}
      else
        operator = value ? 'IN' : 'NOT IN'
        {:conditions => "#{Katello::SyncPlan.table_name}.foreman_tasks_recurring_logic_id #{operator} (#{active_logic_ids.join(',')})"}
      end
    end

    def self.remove_disabled_product(repository)
      if (product = repository.product) && product&.redhat? && (sync_plan = product&.sync_plan) && product&.repositories&.count == 1
        sync_plan.product_ids = (sync_plan.product_ids - [product.id])
        sync_plan.save!
      end
    end

    def product_enabled
      products.each do |product|
        errors.add :base, _("Cannot add product %s because it is disabled.") % product.name if (product.redhat? && !product.enabled?)
      end
    end

    def custom_cron_interval_expression
      errors.add :base, _("Custom cron expression only needs to be set for interval value of custom cron") if cron_status_mismatch?
    end

    def save_with_logic!(enabled = true)
      self.task_group ||= SyncPlanTaskGroup.create!
      self.cron_expression = '' if (self.cron_expression && !(self.interval.eql? CUSTOM_CRON))
      associate_recurring_logic
      self.save!
      start_recurring_logic
      self.foreman_tasks_recurring_logic.enabled = enabled unless (enabled || enabled.nil?)
    end

    def update_attributes_with_logics!(params)
      transaction do
        fail _("No recurring logic tied to the sync plan.") if self.foreman_tasks_recurring_logic.nil?
        params["cron_expression"] = '' if (params.key?("interval") && !params["interval"].eql?(CUSTOM_CRON) && self.interval.eql?(CUSTOM_CRON))
        self.update!(params.except(:enabled))
        if (rec_logic_changed? || (params["enabled"] && !self.enabled? && self.foreman_tasks_recurring_logic.cancelled?))
          old_rec_logic = self.foreman_tasks_recurring_logic
          associate_recurring_logic
          ::Katello::Util::Support.active_record_retry do
            self.save!
          end
          old_rec_logic.reload.cancel
          start_recurring_logic
        end
        toggle_enabled(params[:enabled]) if (params.key?(:enabled) && params[:enabled] != self.enabled?)
      end
    end

    def associate_recurring_logic
      self.foreman_tasks_recurring_logic = add_recurring_logic_to_sync_plan(self.sync_date, self.interval, self.cron_expression)
    end

    def toggle_enabled(value = false)
      self.foreman_tasks_recurring_logic.enabled = value
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

    def enabled?
      self.foreman_tasks_recurring_logic && self.foreman_tasks_recurring_logic.state == 'active'
    end

    def enabled
      enabled?
    end

    def enabled=(value)
      self.foreman_tasks_recurring_logic.enabled = value
    end

    def cancel_recurring_logic
      self.foreman_tasks_recurring_logic&.cancel
    end

    def validate_sync_date
      errors.add :base, _("Start Date and Time can't be blank") if self.sync_date.nil?
    end

    def sync_date_sans_tz
      self.sync_date.strftime('%Y-%m-%d %H:%M:%S %z')
    end

    def next_sync
      return nil unless self.enabled?
      self.foreman_tasks_recurring_logic&.tasks&.order(:start_at)&.last&.start_at
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

    def cron_status_mismatch?
      self.interval != CUSTOM_CRON && !(self.cron_expression.nil? || self.cron_expression.eql?(''))
    end

    def validate_and_update_products(force_update: false)
      sync_plan_products = Product.where(id: self.product_ids).select { |p| p.enabled? }
      return if sync_plan_products.length == self.product_ids.length
      sync_plan_product_ids = sync_plan_products.pluck(:id)
      if sync_plan_product_ids.length < self.product_ids.length
        missing_ids = self.product_ids - sync_plan_product_ids
        Rails.logger.warn "Sync plan products with following ids are either disabled or don't exist: #{missing_ids}"
        if force_update
          Rails.logger.info "Updating sync plan with valid and enabled product ids: #{sync_plan_product_ids}"
          self.product_ids = sync_plan_product_ids
          self.save!
        else
          Rails.logger.warn "Some sync plan products are invalid/disabled. Please run validate_and_update_products(force_update: true) on the sync_plan from `foreman-rake console`"
        end
      end
    end
  end
end
